import Foundation

/// Credenciales ElevenLabs: nunca pongas API keys en Swift versionado.
/// Orden de resolución: variable de entorno `ELEVENLABS_API_KEY` → `ElevenLabsSecrets.plist` en el bundle → nil (voz del sistema).
enum ElevenLabsConfig {
    struct Credentials {
        let apiKey: String
        let voiceId: String
    }

    /// Voz por defecto del proyecto (puedes sobreescribir en plist/env).
    static let defaultVoiceId = "xzZRXG86mSM3naOyL9fa"

    static func loadCredentials() -> Credentials? {
        if let envKey = trim(ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"]), envKey.count >= 16 {
            let voice = trim(ProcessInfo.processInfo.environment["ELEVENLABS_VOICE_ID"]) ?? defaultVoiceId
            return Credentials(apiKey: envKey, voiceId: voice)
        }

        guard let url = Bundle.main.url(forResource: "ElevenLabsSecrets", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String: Any],
              let rawKey = dict["ElevenLabsAPIKey"] as? String else { return nil }

        let key = trim(rawKey)
        guard let key, key != "REPLACE_ME", key.count >= 16 else { return nil }

        let voice = trim(dict["ElevenLabsVoiceID"] as? String) ?? defaultVoiceId
        return Credentials(apiKey: key, voiceId: voice)
    }

    private static func trim(_ s: String?) -> String? {
        guard let s else { return nil }
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}
