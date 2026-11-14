//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation

/// A chat: its title, its messages in order, and when it last changed.
/// `updatedAt` decides the order of the conversation list (newest first).
public struct Conversation: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var title: String
    public var messages: [ChatMessage]
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        messages: [ChatMessage] = [],
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.updatedAt = updatedAt
    }

    public var lastMessagePreview: String {
        messages.last?.text ?? "No messages yet"
    }
}

#if DEBUG

extension Conversation {
    static func mockList() -> [Conversation] {
        [
            Conversation(
                title: "Trip planning",
                messages: [
                    ChatMessage(role: .user, text: "Plan a 3 day trip to Kyoto"),
                    ChatMessage(role: .assistant, text: "Day 1: Fushimi Inari and Gion.")
                ],
                updatedAt: .now
            ),
            Conversation(
                title: "Swift question",
                messages: [ChatMessage(role: .user, text: "What is @Observable?")],
                updatedAt: .now.addingTimeInterval(-3600)
            ),
            Conversation(title: "New chat", updatedAt: .now.addingTimeInterval(-86400))
        ]
    }
}

#endif
