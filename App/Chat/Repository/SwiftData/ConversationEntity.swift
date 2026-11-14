//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class ConversationEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \MessageEntity.conversation)
    var messages: [MessageEntity] = []

    init(id: UUID, title: String, updatedAt: Date) {
        self.id = id
        self.title = title
        self.updatedAt = updatedAt
    }
}

@Model
final class MessageEntity {
    @Attribute(.unique) var id: UUID
    var roleRaw: String
    var text: String
    var createdAt: Date
    /// Keeps the message order stable, because relationship arrays are unordered.
    var position: Int
    var conversation: ConversationEntity?

    init(id: UUID, roleRaw: String, text: String, createdAt: Date, position: Int) {
        self.id = id
        self.roleRaw = roleRaw
        self.text = text
        self.createdAt = createdAt
        self.position = position
    }
}

// MARK: - Mapping

extension ConversationEntity {
    var model: Conversation {
        Conversation(
            id: id,
            title: title,
            messages: messages
                .sorted { $0.position < $1.position }
                .map(\.model),
            updatedAt: updatedAt
        )
    }
}

extension MessageEntity {
    var model: ChatMessage {
        ChatMessage(
            id: id,
            role: ChatMessage.Role(rawValue: roleRaw) ?? .assistant,
            text: text,
            createdAt: createdAt
        )
    }
}
