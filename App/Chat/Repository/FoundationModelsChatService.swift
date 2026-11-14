//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

enum ChatError: LocalizedError {
    case unsupportedOS
    case modelUnavailable(String)
    case conversationTooLong

    var errorDescription: String? {
        switch self {
        case .unsupportedOS:
            "On-device AI needs iOS 26 or later."
        case .modelUnavailable(let reason):
            "On-device AI is unavailable: \(reason)"
        case .conversationTooLong:
            "This conversation is too long for the on-device model. Start a new chat or send a shorter message."
        }
    }
}

/// On-device reply from Apple's Foundation Models (iOS 26+, Apple Intelligence). Free, no API key.
enum FoundationModelsChatService {
    /// How many characters of earlier messages are sent with the newest one. The model has a small
    /// context window, so if a reply fails because the prompt is too long it is tried again with the
    /// next, smaller budget. `0` sends only the newest message.
    static let characterBudgets = [6_000, 2_000, 0]

    static func reply(to history: [ChatMessage]) async throws -> String {
        var text = ""
        for try await partial in replyStream(to: history) {
            text = partial
        }
        return text
    }

    /// Streams the reply. Each element is the whole reply so far.
    static func replyStream(to history: [ChatMessage]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    #if canImport(FoundationModels)
                    guard #available(iOS 26.0, *) else { throw ChatError.unsupportedOS }

                    try await stream(history, into: continuation)
                    continuation.finish()
                    #else
                    throw ChatError.unsupportedOS
                    #endif
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    #if canImport(FoundationModels)
    /// Tries each history budget in turn, moving on only when the prompt was too long and no text
    /// has been produced yet.
    @available(iOS 26.0, *)
    private static func stream(
        _ history: [ChatMessage],
        into continuation: AsyncThrowingStream<String, Error>.Continuation
    ) async throws {
        for (index, budget) in characterBudgets.enumerated() {
            let session = try makeSession()
            var receivedText = false

            do {
                for try await snapshot in session.streamResponse(to: prompt(from: history, characterBudget: budget)) {
                    receivedText = true
                    continuation.yield(snapshot.content)
                }
                return
            } catch {
                guard isContextTooLong(error), !receivedText else { throw error }

                if index == characterBudgets.count - 1 {
                    throw ChatError.conversationTooLong
                }
            }
        }
    }

    @available(iOS 26.0, *)
    private static func isContextTooLong(_ error: Error) -> Bool {
        if let error = error as? LanguageModelSession.GenerationError, case .exceededContextWindowSize = error {
            return true
        }

        if #available(iOS 27.0, *), let error = error as? LanguageModelError, case .contextSizeExceeded = error {
            return true
        }

        return false
    }

    @available(iOS 26.0, *)
    private static func makeSession() throws -> LanguageModelSession {
        switch SystemLanguageModel.default.availability {
        case .available:
            break
        case .unavailable(let reason):
            throw ChatError.modelUnavailable(String(describing: reason))
        }

        return LanguageModelSession(
            instructions: """
            You are a helpful, friendly chat assistant. Keep answers clear and concise.
            Your name is \(Preferences.assistantName). The user's name is \(Preferences.userName).
            """
        )
    }
    #endif

    /// The session is created per call, so earlier turns are replayed as text. Only the most recent
    /// ones that fit in `characterBudget` characters are included, in their original order.
    static func prompt(from history: [ChatMessage], characterBudget: Int = characterBudgets[0]) -> String {
        guard let last = history.last(where: { $0.role == .user }) else { return "" }

        var used = 0
        var earlier: [ChatMessage] = []

        for message in history.prefix(while: { $0.id != last.id }).reversed() {
            used += message.text.count
            if used > characterBudget { break }
            earlier.insert(message, at: 0)
        }

        guard !earlier.isEmpty else { return last.text }

        let context = earlier
            .map { "\($0.role == .user ? "User" : "Assistant"): \($0.text)" }
            .joined(separator: "\n")
        return "Conversation so far:\n\(context)\n\nReply to the user's latest message:\n\(last.text)"
    }
}
