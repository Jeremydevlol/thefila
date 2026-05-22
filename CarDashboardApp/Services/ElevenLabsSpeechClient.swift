import Foundation

enum ElevenLabsSpeechClientError: Error {
    case badURL
    case http(Int, String?)
}

/// Cliente REST oficial ElevenLabs (text-to-speech → MP3).
enum ElevenLabsSpeechClient {
    private static let baseURL = "https://api.elevenlabs.io/v1/text-to-speech/"

    /// Genera MP3 binario (`audio/mpeg`) para un fragmento de texto (modelo multilingüe).
    static func synthesizeChunkToMP3(apiKey: String, voiceId: String, text: String) async throws -> Data {
        let pathVoice = voiceId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? voiceId
        guard let url = URL(string: Self.baseURL + pathVoice) else {
            throw ElevenLabsSpeechClientError.badURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.timeoutInterval = 180
        req.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        req.setValue("audio/mpeg", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "text": text,
            "model_id": "eleven_multilingual_v2",
            "voice_settings": [
                "stability": 0.52,
                "similarity_boost": 0.78,
            ]
        ]

        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            let snippet = String(data: data.prefix(280), encoding: .utf8)
            throw ElevenLabsSpeechClientError.http(http.statusCode, snippet)
        }
        guard !data.isEmpty else {
            throw ElevenLabsSpeechClientError.http(http.statusCode, "empty_body")
        }
        return data
    }
}
