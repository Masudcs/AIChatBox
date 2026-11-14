//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation

/// Produces the assistant's reply for a conversation. Tests pass a stub implementation.
public protocol IChatRepository: Sendable {
    /// Returns the whole assistant reply for the given conversation history.
    func reply(to history: [ChatMessage]) async throws -> ChatMessage

    /// Streams the reply as it is written. Each element is the whole reply so far, not just the
    /// new piece, so the latest element is always the text to show.
    func replyStream(to history: [ChatMessage]) -> AsyncThrowingStream<String, Error>
}

public extension IChatRepository {
    /// Repositories that cannot stream deliver the whole reply as a single element.
    func replyStream(to history: [ChatMessage]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    continuation.yield(try await reply(to: history).text)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
