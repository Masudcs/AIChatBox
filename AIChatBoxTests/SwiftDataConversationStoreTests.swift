//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import XCTest
@testable import AIChatBox

final class SwiftDataConversationStoreTests: XCTestCase {
    private func makeStore() throws -> SwiftDataConversationStore {
        SwiftDataConversationStore(modelContainer: try SwiftDataConversationStore.makeContainer(inMemory: true))
    }

    func test_save_whenLoadedBack_shouldKeepMessageOrder() async throws {
        let store = try makeStore()
        let messages = (0..<5).map { ChatMessage(role: $0.isMultiple(of: 2) ? .user : .assistant, text: "m\($0)") }
        let conversation = Conversation(title: "Hello", messages: messages)

        try await store.save(conversation)

        let loaded = try await store.conversation(id: conversation.id)
        XCTAssertEqual(loaded?.title, "Hello")
        XCTAssertEqual(loaded?.messages.map(\.text), ["m0", "m1", "m2", "m3", "m4"])
        XCTAssertEqual(loaded?.messages.map(\.role), messages.map(\.role))
    }

    func test_save_whenSavedAgain_shouldUpdateInsteadOfDuplicate() async throws {
        let store = try makeStore()
        var conversation = Conversation(title: "A", messages: [ChatMessage(role: .user, text: "one")])
        try await store.save(conversation)

        conversation.messages.append(ChatMessage(role: .assistant, text: "two"))
        conversation.title = "B"
        try await store.save(conversation)

        let all = try await store.conversations()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.title, "B")
        XCTAssertEqual(all.first?.messages.map(\.text), ["one", "two"])
    }

    func test_conversations_whenSeveralSaved_shouldSortNewestFirstAndSupportDelete() async throws {
        let store = try makeStore()
        let old = Conversation(title: "old", updatedAt: Date(timeIntervalSince1970: 100))
        let new = Conversation(title: "new", updatedAt: Date(timeIntervalSince1970: 200))
        try await store.save(old)
        try await store.save(new)

        let titles = try await store.conversations().map(\.title)
        XCTAssertEqual(titles, ["new", "old"])

        try await store.delete(id: new.id)
        let remaining = try await store.conversations().map(\.title)
        XCTAssertEqual(remaining, ["old"])
    }
}
