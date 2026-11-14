//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation
@testable import AIChatBox

struct StoreError: LocalizedError {
    var errorDescription: String? { "The database is unavailable." }
}

/// An in-memory store that throws while `shouldFail` is true, to test error handling and retry.
actor FailingConversationStore: IConversationStore {
    private let base = InMemoryConversationStore()
    private var shouldFail = false

    func setShouldFail(_ value: Bool) {
        shouldFail = value
    }

    func conversations() async throws -> [Conversation] {
        try check()
        return await base.conversations()
    }

    func conversation(id: UUID) async throws -> Conversation? {
        try check()
        return await base.conversation(id: id)
    }

    func save(_ conversation: Conversation) async throws {
        try check()
        await base.save(conversation)
    }

    func delete(id: UUID) async throws {
        try check()
        await base.delete(id: id)
    }

    private func check() throws {
        if shouldFail { throw StoreError() }
    }
}
