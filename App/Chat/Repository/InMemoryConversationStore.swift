//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation

/// Keeps conversations in memory only; everything is lost when the app quits.
/// Used by tests and previews. The app itself uses `AppConversationStore`.
public actor InMemoryConversationStore: IConversationStore {
    private var items: [UUID: Conversation]

    public init(seed: [Conversation] = []) {
        items = Dictionary(uniqueKeysWithValues: seed.map { ($0.id, $0) })
    }

    public func conversations() -> [Conversation] {
        items.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    public func conversation(id: UUID) -> Conversation? {
        items[id]
    }

    public func save(_ conversation: Conversation) {
        items[conversation.id] = conversation
    }

    public func delete(id: UUID) {
        items[id] = nil
    }
}
