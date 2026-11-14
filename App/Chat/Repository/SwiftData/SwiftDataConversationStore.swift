//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation
import SwiftData

/// Persists conversations on disk with SwiftData.
@ModelActor
public actor SwiftDataConversationStore: IConversationStore {
    public static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        return try ModelContainer(
            for: ConversationEntity.self, MessageEntity.self,
            configurations: configuration
        )
    }

    public func conversations() throws -> [Conversation] {
        let descriptor = FetchDescriptor<ConversationEntity>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map(\.model)
    }

    public func conversation(id: UUID) throws -> Conversation? {
        try entity(id: id)?.model
    }

    public func save(_ conversation: Conversation) throws {
        let entity = try entity(id: conversation.id) ?? {
            let new = ConversationEntity(id: conversation.id, title: conversation.title, updatedAt: conversation.updatedAt)
            modelContext.insert(new)
            return new
        }()

        entity.title = conversation.title
        entity.updatedAt = conversation.updatedAt

        // Replace the messages so edits, reordering and removals are all reflected.
        for old in entity.messages {
            modelContext.delete(old)
        }
        entity.messages = conversation.messages.enumerated().map { index, message in
            MessageEntity(
                id: message.id,
                roleRaw: message.role.rawValue,
                text: message.text,
                createdAt: message.createdAt,
                position: index
            )
        }

        try modelContext.save()
    }

    public func delete(id: UUID) throws {
        guard let entity = try entity(id: id) else { return }
        modelContext.delete(entity)
        try modelContext.save()
    }

    private func entity(id: UUID) throws -> ConversationEntity? {
        var descriptor = FetchDescriptor<ConversationEntity>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
