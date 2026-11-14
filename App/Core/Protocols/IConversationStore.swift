//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation

/// Where conversations are kept. Screens and view models only use this protocol, so the storage
/// can be swapped: `AppConversationStore` (SwiftData) in the app, `InMemoryConversationStore` in
/// tests and previews.
///
/// Every method can throw (for example a database error). Callers turn the error into a
/// `UIState.failure` or an error message so the user can retry.
public protocol IConversationStore: Sendable {
    /// All conversations, newest `updatedAt` first.
    func conversations() async throws -> [Conversation]

    /// One conversation with its messages in order, or nil if it does not exist.
    func conversation(id: UUID) async throws -> Conversation?

    /// Inserts the conversation, or replaces the stored one with the same `id`.
    func save(_ conversation: Conversation) async throws

    /// Removes the conversation and its messages. Does nothing if it does not exist.
    func delete(id: UUID) async throws

    /// Set while chats are not being saved to disk, so the screens can tell the user.
    var storageWarning: String? { get async }

    /// Tries again to use the on-disk database. Returns true when chats are saved to disk.
    func reopenStorage() async -> Bool
}

public extension IConversationStore {
    /// Stores that always save normally have nothing to warn about.
    var storageWarning: String? {
        get async { nil }
    }

    func reopenStorage() async -> Bool {
        true
    }
}
