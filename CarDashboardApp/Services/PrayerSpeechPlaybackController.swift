import AVFoundation
import Combine
import MediaPlayer
import UIKit

/// Metadatos mostrados en Bloqueado / Centro de control (Now Playing).
struct PrayerSpeechNowPlayingTitles: Equatable {
    let title: String
    let artist: String
    let album: String
}

/// Lectura por voz: ElevenLabs (cuando hay credenciales) o voz del sistema (`AVSpeechSynthesizer`).
/// Now Playing usa duración real en modo nube cuando el recurso está cargado; estimación UTF-16 en modo sistema.
final class PrayerSpeechPlaybackController: NSObject, ObservableObject {
    @Published private(set) var progress: Double = 0
    @Published private(set) var isSpeaking: Bool = false
    @Published private(set) var estimatedDurationSeconds: Double = 180

    /// Generando audio ElevenLabs (descarga antes de reproducir).
    @Published private(set) var isGeneratingCloudVoice: Bool = false

    private let synthesizer = AVSpeechSynthesizer()

    /// Texto íntegro (modo síntesis del sistema usa UTF‑16 incremental; modo ElevenLabs para sesión/metadata).
    private var fullText: NSString = ""
    private var baseUtf16Prefix: Int = 0
    private var lastReachedUtf16: Int = 0
    private var chosenLanguage: PrayerLanguage = .spanish

    private var playbackSessionSignature: Int?
    private var nowPlayingTitles: PrayerSpeechNowPlayingTitles?

    private var nowPlayingHeartbeat: AnyCancellable?

    /// ElevenLabs / AVPlayer local
    private var elevenLabsTask: Task<Void, Never>?
    private var cloudPlayer: AVPlayer?
    private var cloudTimeObserverToken: Any?
    private var cloudItemEndObserver: NSObjectProtocol?
    private var elevenLabsTempFileURL: URL?

    /// `true` desde que el MP3 de ElevenLabs está listo hasta `teardown`; evita usar `AVSpeech`/`AVPlayer` desde hilos mezclados.
    private var cloudPlaybackActive: Bool = false

    private let elevenLabsCharsPerChunk = 8_900

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSessionBaseline()
        installRemoteCommands()
    }

    deinit {
        teardownCloudPlayback()
        nowPlayingHeartbeat?.cancel()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Audio session

    private func configureAudioSessionBaseline() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: [])
        } catch {}
    }

    private func activateSessionBeforeSpeaking() {
        configureAudioSessionBaseline()
    }

    // MARK: Sesión pública

    func preparePrayerPlaybackIfNeeded(
        signature: Int,
        prayerText: String,
        language: PrayerLanguage,
        titles: PrayerSpeechNowPlayingTitles
    ) {
        nowPlayingTitles = titles

        let isNewUtterance = playbackSessionSignature != signature
        playbackSessionSignature = signature

        if isNewUtterance {
            rebuildUtteranceState(prayerText: prayerText, language: language)
        }

        configureAudioSessionBaseline()
        startNowPlayingHeartbeatIfNeeded()
        publishNowPlayingSnapshot()
    }

    func endLocalPlayerSession() {
        playbackSessionSignature = nil
        nowPlayingTitles = nil
        cancelNowPlayingHeartbeat()
        teardownCloudPlayback()

        synthesizer.stopSpeaking(at: .immediate)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isSpeaking = false
            self.progress = 0
            self.isGeneratingCloudVoice = false
        }

        baseUtf16Prefix = 0
        lastReachedUtf16 = 0
        fullText = ""
        estimatedDurationSeconds = 180

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    // MARK: Rebuild contenido

    private func rebuildUtteranceState(prayerText: String, language: PrayerLanguage) {
        chosenLanguage = language
        elevenLabsTask?.cancel()
        teardownCloudPlayback()
        synthesizer.stopSpeaking(at: .immediate)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isSpeaking = false
            self.progress = 0
        }

        baseUtf16Prefix = 0
        lastReachedUtf16 = 0

        let trimmed = prayerText.trimmingCharacters(in: .whitespacesAndNewlines)
        let content: String
        if trimmed.isEmpty {
            content = TefilaCopy.choose(
                "Tu tefilá aparecerá aquí para escucharla en cuanto esté lista.",
                "Your prayer will appear here to listen when it is ready.",
                "התפילה שלך תופיע כאן להאזנה כשתהיה מוכנה."
            )
        } else {
            content = trimmed
        }

        fullText = content as NSString
        let len = max(fullText.length, 1)
        estimatedDurationSeconds = max(45, Double(len) * 0.048)

        if ElevenLabsConfig.loadCredentials() != nil {
            startElevenLabsPipeline(fullText: String(fullText))
        } else {
            DispatchQueue.main.async { [weak self] in self?.isGeneratingCloudVoice = false }
        }
    }

    // MARK: ElevenLabs pipeline

    private func startElevenLabsPipeline(fullText: String) {
        elevenLabsTask?.cancel()

        DispatchQueue.main.async { [weak self] in self?.isGeneratingCloudVoice = true }

        elevenLabsTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }

            defer {
                if Task.isCancelled {
                    Task { @MainActor in self.isGeneratingCloudVoice = false }
                }
            }

            guard let cred = ElevenLabsConfig.loadCredentials() else {
                Task { @MainActor in self.isGeneratingCloudVoice = false }
                return
            }

            let pieces = Self.chunkForElevenLabs(fullText, maxChars: self.elevenLabsCharsPerChunk)
            guard !pieces.isEmpty else {
                Task { @MainActor in self.isGeneratingCloudVoice = false }
                return
            }

            do {
                var mp3Combined = Data()
                for fragment in pieces {
                    if Task.isCancelled { return }
                    let chunkData = try await ElevenLabsSpeechClient.synthesizeChunkToMP3(
                        apiKey: cred.apiKey,
                        voiceId: cred.voiceId,
                        text: fragment
                    )
                    mp3Combined.append(chunkData)
                }

                guard !Task.isCancelled else { return }

                let outURL: URL
                do {
                    outURL = try Self.writeTempMp3(mp3Combined)
                } catch {
                    Task { @MainActor in self.isGeneratingCloudVoice = false }
                    return
                }

                await MainActor.run {
                    guard !Task.isCancelled else {
                        try? FileManager.default.removeItem(at: outURL)
                        return
                    }
                    self.attachElevenLabsPlayer(with: outURL)
                }
            } catch {
                Task { @MainActor in self.isGeneratingCloudVoice = false }
                // Sin credenciales o error de red → se usa sólo modo sistema al pulsar play.
            }
        }
    }

    private static func chunkForElevenLabs(_ raw: String, maxChars: Int) -> [String] {
        if raw.count <= maxChars { return [raw] }
        var out: [String] = []
        var rest = raw[...]

        while !rest.isEmpty {
            if rest.count <= maxChars {
                out.append(String(rest))
                break
            }

            let hardEndIdx = rest.index(rest.startIndex, offsetBy: maxChars)
            let window = rest[..<hardEndIdx]

            let cut: String.Index
            if let r = window.range(of: "\n\n", options: .backwards) {
                cut = r.upperBound
            } else if let r = window.range(of: "\n", options: .backwards) {
                cut = r.upperBound
            } else {
                cut = hardEndIdx
            }

            if cut == rest.startIndex {
                out.append(String(window))
                rest = rest[hardEndIdx...]
            } else {
                out.append(String(rest[..<cut]))
                rest = rest[cut...]
            }
        }
        return out.filter { !$0.isEmpty }
    }

    private static func writeTempMp3(_ bytes: Data) throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("tefila-eleven-\(UUID().uuidString).mp3")
        try? FileManager.default.removeItem(at: url)
        try bytes.write(to: url)
        return url
    }

    /// Debe ejecutarse en el hilo principal.
    private func attachElevenLabsPlayer(with url: URL) {
        teardownCloudPlayback()
        elevenLabsTempFileURL = url

        synthesizer.stopSpeaking(at: .immediate)

        cloudPlayer = AVPlayer(url: url)
        cloudPlayer?.actionAtItemEnd = .pause

        cloudItemEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: cloudPlayer?.currentItem,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.isSpeaking = false
            self.progress = 1
            self.publishNowPlayingSnapshot()
        }

        configureAudioDurationFromAsset(for: cloudPlayer?.currentItem)

        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        cloudTimeObserverToken = cloudPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self, self.cloudPlaybackActive else { return }
            guard let durSec = self.cloudPlayer?.currentItem?.duration.secondsOptional, durSec > 0 else { return }

            let secs = CMTimeGetSeconds(time)
            let safeTotal = max(durSec, 1)
            self.progress = max(0, min(1, secs / safeTotal))
            self.estimatedDurationSeconds = safeTotal
            self.publishNowPlayingSnapshot()
        }

        DispatchQueue.main.async {
            self.cloudPlaybackActive = true
            self.isGeneratingCloudVoice = false
            self.publishNowPlayingSnapshot()
        }
    }

    private func configureAudioDurationFromAsset(for item: AVPlayerItem?) {
        guard let asset = item?.asset else { return }
        Task {
            guard let dur = try? await asset.load(.duration) else { return }
            let seconds = CMTimeGetSeconds(dur)
            guard seconds.isFinite && seconds > 1 else { return }
            await MainActor.run {
                self.estimatedDurationSeconds = seconds
                self.publishNowPlayingSnapshot()
            }
        }
    }

    private func teardownCloudPlayback() {
        cloudPlaybackActive = false

        if let tok = cloudTimeObserverToken, let p = cloudPlayer {
            p.removeTimeObserver(tok)
        }
        cloudTimeObserverToken = nil

        if let cloudItemEndObserver {
            NotificationCenter.default.removeObserver(cloudItemEndObserver)
        }
        cloudItemEndObserver = nil

        cloudPlayer?.pause()
        cloudPlayer?.replaceCurrentItem(with: nil)
        cloudPlayer = nil

        if let u = elevenLabsTempFileURL {
            try? FileManager.default.removeItem(at: u)
        }
        elevenLabsTempFileURL = nil
    }

    // MARK: Repro local

    private var usingCloudPlayback: Bool {
        cloudPlaybackActive
    }

    private func speechPlaybackRateEffective() -> Double {
        usingCloudPlayback
            ? ((cloudPlayer?.rate ?? 0) > 0 ? 1.0 : 0.0)
            : ((synthesizer.isSpeaking && !synthesizer.isPaused) ? 1.0 : 0.0)
    }

    func togglePlayPause() {
        if usingCloudPlayback {
            if (cloudPlayer?.rate ?? 0) > 0 {
                cloudPlayer?.pause()
                isSpeaking = false
            } else {
                activateSessionBeforeSpeaking()
                cloudPlayer?.play()
                isSpeaking = true
            }
            publishNowPlayingSnapshot()
            return
        }

        if synthesizer.isSpeaking {
            if synthesizer.isPaused {
                activateSessionBeforeSpeaking()
                synthesizer.continueSpeaking()
                DispatchQueue.main.async { [weak self] in
                    self?.isSpeaking = true
                    self?.publishNowPlayingSnapshot()
                }
            } else {
                synthesizer.pauseSpeaking(at: .word)
                DispatchQueue.main.async { [weak self] in
                    self?.isSpeaking = false
                    self?.publishNowPlayingSnapshot()
                }
            }
            return
        }
        if progress >= 0.97 {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.cloudPlaybackActive {
                    self.cloudPlayer?.pause()
                    self.cloudPlayerSeekToPortionOrRestart(0)
                    self.activateSessionBeforeSpeaking()
                    self.cloudPlayer?.play()
                    self.isSpeaking = true
                    self.publishNowPlayingSnapshot()
                } else {
                    self.synthesizer.stopSpeaking(at: .immediate)
                    self.progress = 0
                    self.lastReachedUtf16 = 0
                    self.baseUtf16Prefix = 0
                    self.isSpeaking = false
                    self.publishNowPlayingSnapshot()
                    self.startFromUtf16Offset(0)
                }
            }
            return
        }
        startFromUtf16Offset(lastReachedUtf16)
    }

    func seekToBeginning() {
        if usingCloudPlayback {
            cloudPlayer?.pause()
            cloudPlayerSeekToPortionOrRestart(0)
            isSpeaking = false
            progress = 0
            publishNowPlayingSnapshot()
            return
        }
        synthesizer.stopSpeaking(at: .immediate)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.progress = 0
            self.lastReachedUtf16 = 0
            self.baseUtf16Prefix = 0
            self.isSpeaking = false
            self.publishNowPlayingSnapshot()
        }
    }

    func skip(seconds: Double) {
        if cloudPlaybackActive, let cp = cloudPlayer {
            let totalSec = cp.currentItem?.duration.secondsOptional ?? max(estimatedDurationSeconds, 1)
            guard totalSec.isFinite && totalSec > 0 else { return }

            let wasPlaying = cp.rate > 0
            cp.pause()

            let curSec = CMTimeGetSeconds(cp.currentTime())
            let targetSec = max(0, min(totalSec - 0.05, curSec + seconds))

            targetSeekOnPlayer(
                CMTime(seconds: targetSec, preferredTimescale: 60_000),
                resumePlaying: wasPlaying
            )
            return
        }

        let delta = seconds / max(estimatedDurationSeconds, 1)
        let newP = min(1, max(0, progress + delta))
        seekToProgress(newP)
    }

    func seekToProgress(_ p: Double) {
        guard hasActivePlaybackSession else { return }
        let clamped = min(1, max(0, p))

        if usingCloudPlayback {
            cloudSeekToFractionLinear(clamped)
            return
        }

        let target = Int(Double(fullText.length) * clamped)
        stopSpeechEngineOnly()
        startFromUtf16Offset(min(max(0, target), fullText.length))
    }

    private func cloudSeekToFractionLinear(_ portion: Double) {
        guard let dur = cloudPlayer?.currentItem?.duration.secondsOptional else {
            return
        }

        let wasPlaying = (cloudPlayer?.rate ?? 0) > 0
        cloudPlayer?.pause()

        targetSeekOnPlayer(
            CMTime(seconds: dur * Double(portion), preferredTimescale: 60_000),
            resumePlaying: wasPlaying
        )
    }

    private func cloudPlayerSeekToPortionOrRestart(_ portion: Double) {
        guard cloudPlaybackActive, let elevenLabsTempFileURL else {
            cloudPlayer?.pause()
            return
        }

        rebuildCloudPlayerKeepingFile(elevenLabsTempFileURL)
        activateSessionBeforeSpeaking()

        guard let dur = cloudPlayer?.currentItem?.duration.secondsOptional, dur > 0 else {
            DispatchQueue.main.async { [weak self] in
                self?.progress = portion >= 1 ? 1 : portion
                self?.publishNowPlayingSnapshot()
            }
            return
        }

        cloudPlayer?.pause()
        targetSeekOnPlayer(CMTime(seconds: dur * Double(portion), preferredTimescale: 60_000))

        DispatchQueue.main.async { [weak self] in self?.publishNowPlayingSnapshot() }
    }

    private func rebuildCloudPlayerKeepingFile(_ url: URL) {
        if let tok = cloudTimeObserverToken, let p = cloudPlayer {
            p.removeTimeObserver(tok)
        }
        cloudTimeObserverToken = nil

        if let cloudItemEndObserver {
            NotificationCenter.default.removeObserver(cloudItemEndObserver)
        }
        cloudItemEndObserver = nil

        cloudPlayer?.pause()
        cloudPlayer?.replaceCurrentItem(with: nil)
        cloudPlayer = nil

        cloudPlayer = AVPlayer(url: url)
        cloudPlayer?.actionAtItemEnd = .pause

        cloudItemEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: cloudPlayer?.currentItem,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.isSpeaking = false
            self.progress = 1
            self.publishNowPlayingSnapshot()
        }

        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        cloudTimeObserverToken = cloudPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self, let durSec = self.cloudPlayer?.currentItem?.duration.secondsOptional, durSec > 0 else { return }
            let secs = CMTimeGetSeconds(time)
            let safeTotal = max(durSec, 1)
            self.progress = max(0, min(1, secs / safeTotal))
            self.estimatedDurationSeconds = safeTotal
            self.publishNowPlayingSnapshot()
        }

        configureAudioDurationFromAsset(for: cloudPlayer?.currentItem)
    }

    /// Busca usando tolerancias locales (MP3 en disco).
    private func targetSeekOnPlayer(_ time: CMTime, resumePlaying: Bool = false) {
        cloudPlayer?.seek(
            to: time,
            toleranceBefore: CMTime(seconds: 0.06, preferredTimescale: 1000),
            toleranceAfter: CMTime(seconds: 0.06, preferredTimescale: 1000)
        ) { [weak self] finished in
            guard let self else { return }
            if finished, resumePlaying {
                self.activateSessionBeforeSpeaking()
                self.cloudPlayer?.play()
                self.isSpeaking = true
            }
            self.publishNowPlayingSnapshot()
        }
    }

    private var hasActivePlaybackSession: Bool {
        playbackSessionSignature != nil && fullText.length > 0
    }

    private func stopSpeechEngineOnly() {
        synthesizer.stopSpeaking(at: .immediate)
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.publishNowPlayingSnapshot()
        }
    }

    private func startFromUtf16Offset(_ utf16Offset: Int) {
        guard !usingCloudPlayback else {
            activateSessionBeforeSpeaking()
            cloudPlayer?.play()
            isSpeaking = true
            publishNowPlayingSnapshot()
            return
        }

        guard hasActivePlaybackSession else { return }

        let start = min(max(0, utf16Offset), fullText.length)
        if start >= fullText.length {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.progress = 1
                self.lastReachedUtf16 = self.fullText.length
                self.isSpeaking = false
                self.publishNowPlayingSnapshot()
            }
            return
        }

        let range = NSRange(location: start, length: fullText.length - start)
        let sub = fullText.substring(with: range)
        baseUtf16Prefix = start
        lastReachedUtf16 = start

        let utterance = AVSpeechUtterance(string: sub)
        utterance.voice = voice(for: chosenLanguage)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.94
        utterance.preUtteranceDelay = 0.06
        utterance.postUtteranceDelay = 0.05

        activateSessionBeforeSpeaking()
        synthesizer.speak(utterance)
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = true
            self?.publishNowPlayingSnapshot()
        }
    }

    private func voice(for language: PrayerLanguage) -> AVSpeechSynthesisVoice? {
        let id: String
        switch language {
        case .spanish: id = "es-ES"
        case .english: id = "en-US"
        case .hebrew: id = "he-IL"
        }
        return AVSpeechSynthesisVoice(language: id) ?? AVSpeechSynthesisVoice(language: "es-ES")
    }

    // MARK: Now Playing

    private func startNowPlayingHeartbeatIfNeeded() {
        guard playbackSessionSignature != nil else { return }
        cancelNowPlayingHeartbeat()
        nowPlayingHeartbeat = Timer.publish(every: 0.45, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.publishNowPlayingSnapshot()
            }
    }

    private func cancelNowPlayingHeartbeat() {
        nowPlayingHeartbeat?.cancel()
        nowPlayingHeartbeat = nil
    }

    private func publishNowPlayingSnapshot() {
        guard playbackSessionSignature != nil else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var info: [String: Any] = [:]

        let duration: Double = {
            if usingCloudPlayback, let secs = cloudPlayer?.currentItem?.duration.secondsOptional, secs > 0 {
                max(secs, 1)
            } else {
                max(estimatedDurationSeconds, 1)
            }
        }()

        let elapsed = min(duration, max(0, progress * duration))
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsed
        info[MPNowPlayingInfoPropertyPlaybackRate] = speechPlaybackRateEffective()

        if let t = nowPlayingTitles {
            info[MPMediaItemPropertyTitle] = t.title
            info[MPMediaItemPropertyArtist] = t.artist
            info[MPMediaItemPropertyAlbumTitle] = t.album
        }

        if let artwork = Self.makeThumbnailArtwork() {
            info[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private static func makeThumbnailArtwork() -> MPMediaItemArtwork? {
        let fallbackSize = CGSize(width: 512, height: 512)
        if let ui = UIImage(named: "TefilaLogo") {
            let size = ui.size.width > 0 && ui.size.height > 0 ? ui.size : fallbackSize
            return MPMediaItemArtwork(boundsSize: size) { _ in ui }
        }
        let cfg = UIImage.SymbolConfiguration(pointSize: 220, weight: .regular)
        guard let sys = UIImage(systemName: "star.of.david.fill", withConfiguration: cfg) else { return nil }
        let tinted = sys.withTintColor(.label, renderingMode: .alwaysTemplate)
        return MPMediaItemArtwork(boundsSize: fallbackSize) { _ in tinted }
    }

    // MARK: Remote commands · MPRemoteCommandCenter

    private func installRemoteCommands() {
        let c = MPRemoteCommandCenter.shared()

        c.togglePlayPauseCommand.isEnabled = true
        c.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            return self.runRemoteCommandBody { self.togglePlayPause() }
        }

        c.playCommand.isEnabled = true
        c.playCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            return self.runRemoteCommandBody { self.handleRemotePlay() }
        }

        c.pauseCommand.isEnabled = true
        c.pauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            return self.runRemoteCommandBody { self.handleRemotePause() }
        }

        c.skipForwardCommand.isEnabled = true
        c.skipForwardCommand.preferredIntervals = [NSNumber(value: 15)]
        c.skipForwardCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            return self.runRemoteCommandBody { self.skip(seconds: 15) }
        }

        c.skipBackwardCommand.isEnabled = true
        c.skipBackwardCommand.preferredIntervals = [NSNumber(value: 15)]
        c.skipBackwardCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            return self.runRemoteCommandBody { self.skip(seconds: -15) }
        }

        c.changePlaybackPositionCommand.isEnabled = true
        c.changePlaybackPositionCommand.addTarget { [weak self] evt in
            guard let self, let positionEvent = evt as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            let pos = positionEvent.positionTime
            return self.runRemoteCommandBody {
                let duration = max(self.estimatedDurationSeconds, 1)
                let frac = max(0, min(1, pos / duration))
                self.seekToProgress(frac)
            }
        }

        c.nextTrackCommand.isEnabled = false
        c.previousTrackCommand.isEnabled = false
        c.seekForwardCommand.isEnabled = false
        c.seekBackwardCommand.isEnabled = false

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Self.handleAudioInterruptionNotification(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @discardableResult
    private func runRemoteCommandBody(_ body: @escaping () -> Void) -> MPRemoteCommandHandlerStatus {
        if Thread.isMainThread {
            guard hasActivePlaybackSession else { return .commandFailed }
            body()
            publishNowPlayingSnapshot()
            return .success
        }
        var status = MPRemoteCommandHandlerStatus.commandFailed
        DispatchQueue.main.sync {
            guard hasActivePlaybackSession else {
                status = .commandFailed
                return
            }
            body()
            publishNowPlayingSnapshot()
            status = .success
        }
        return status
    }

    private func handleRemotePlay() {
        guard hasActivePlaybackSession else { return }
        if cloudPlaybackActive {
            if progress >= 0.97 {
                cloudPlayer?.pause()
                cloudPlayerSeekToPortionOrRestart(0)
                activateSessionBeforeSpeaking()
                cloudPlayer?.play()
                isSpeaking = true
                publishNowPlayingSnapshot()
                return
            }
            if (cloudPlayer?.rate ?? 0) == 0 {
                activateSessionBeforeSpeaking()
                cloudPlayer?.play()
                isSpeaking = true
            }
            publishNowPlayingSnapshot()
            return
        }
        if synthesizer.isSpeaking && synthesizer.isPaused {
            activateSessionBeforeSpeaking()
            synthesizer.continueSpeaking()
            isSpeaking = true
            publishNowPlayingSnapshot()
            return
        }
        if synthesizer.isSpeaking && !synthesizer.isPaused { return }
        if progress >= 0.97 || lastReachedUtf16 >= max(fullText.length - 1, 0) {
            synthesizer.stopSpeaking(at: .immediate)
            progress = 0
            lastReachedUtf16 = 0
            baseUtf16Prefix = 0
            isSpeaking = false
            publishNowPlayingSnapshot()
            startFromUtf16Offset(0)
            return
        }
        startFromUtf16Offset(lastReachedUtf16)
    }

    private func handleRemotePause() {
        if cloudPlaybackActive {
            cloudPlayer?.pause()
            isSpeaking = false
            publishNowPlayingSnapshot()
            return
        }
        guard synthesizer.isSpeaking, !synthesizer.isPaused else { return }
        synthesizer.pauseSpeaking(at: .word)
        isSpeaking = false
        publishNowPlayingSnapshot()
    }

    @objc private func handleAudioInterruptionNotification(_ note: Notification) {
        DispatchQueue.main.async { [weak self] in self?.publishNowPlayingSnapshot() }
    }
}

// MARK: - AVSpeech delegate (sólo modo sistema)

extension PrayerSpeechPlaybackController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        guard !cloudPlaybackActive else { return }
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = true
            self?.publishNowPlayingSnapshot()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        guard !cloudPlaybackActive else { return }
        let absoluteEnd = baseUtf16Prefix + NSMaxRange(characterRange)
        let maxLen = max(fullText.length, 1)
        lastReachedUtf16 = min(max(absoluteEnd, 0), fullText.length)
        let p = min(1, Double(lastReachedUtf16) / Double(maxLen))
        DispatchQueue.main.async { [weak self] in
            self?.progress = p
            self?.publishNowPlayingSnapshot()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard !cloudPlaybackActive else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isSpeaking = false
            if self.lastReachedUtf16 >= self.fullText.length - 1 || self.progress > 0.98 {
                self.progress = 1
                self.lastReachedUtf16 = self.fullText.length
            }
            self.publishNowPlayingSnapshot()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        guard !cloudPlaybackActive else { return }
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.publishNowPlayingSnapshot()
        }
    }
}

private extension CMTime {
    var secondsOptional: Double? {
        guard isNumeric, !isIndefinite else { return nil }
        let sec = CMTimeGetSeconds(self)
        guard sec.isFinite, sec > 0 else { return nil }
        return sec
    }
}
