//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation

/// Replies with the on-device Foundation Models. Throws if they can't be used.
public struct ChatRepository: IChatRepository {
    public init() {}

    public func reply(to history: [ChatMessage]) async throws -> ChatMessage {
        let text = try await FoundationModelsChatService.reply(to: history)
        return ChatMessage(role: .assistant, text: text)
    }

    public func replyStream(to history: [ChatMessage]) -> AsyncThrowingStream<String, Error> {
        FoundationModelsChatService.replyStream(to: history)
    }
}
