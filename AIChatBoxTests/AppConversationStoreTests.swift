//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import XCTest
@testable import AIChatBox

/// Lets a test turn the "disk" on and off.
private final class DiskSwitch: @unchecked Sendable {
    var isDown = true
}

private struct DiskError: LocalizedError {
    var errorDescription: String? { "disk is full" }
}

final class AppConversationStoreTests: XCTestCase {
    private func makeStore(_ disk: DiskSwitch) -> AppConversationStore {
        AppConversationStore {
            if disk.isDown { throw DiskError() }
            return try SwiftDataConversationStore.makeContainer(inMemory: true)
        }
    }

    func test_init_whenDatabaseOpens_shouldHaveNoWarning() async {
        let disk = DiskSwitch()
        disk.isDown = false

        let warning = await makeStore(disk).storageWarning

        XCTAssertNil(warning)
    }

    func test_init_whenDatabaseCannotOpen_shouldWarnAndStillSave() async throws {
        let store = makeStore(DiskSwitch())

        let storageWarning = await store.storageWarning
        let warning = try XCTUnwrap(storageWarning)
        XCTAssertTrue(warning.contains("disk is full"))

        let conversation = Conversation(title: "Still works")
        try await store.save(conversation)
        let loaded = try await store.conversation(id: conversation.id)
        XCTAssertEqual(loaded?.title, "Still works")
    }

    func test_reopenStorage_whenDatabaseComesBack_shouldMoveChatsAndClearWarning() async throws {
        let disk = DiskSwitch()
        let store = makeStore(disk)
        let conversation = Conversation(title: "Made while offline", messages: [ChatMessage(role: .user, text: "hi")])
        try await store.save(conversation)

        disk.isDown = false
        let reopened = await store.reopenStorage()

        XCTAssertTrue(reopened)
        let warning = await store.storageWarning
        XCTAssertNil(warning)
        let all = try await store.conversations()
        XCTAssertEqual(all.map(\.title), ["Made while offline"])
        XCTAssertEqual(all.first?.messages.map(\.text), ["hi"])
    }

    func test_reopenStorage_whenDatabaseStillDown_shouldFailAndKeepWarning() async {
        let store = makeStore(DiskSwitch())

        let reopened = await store.reopenStorage()

        XCTAssertFalse(reopened)
        let warning = await store.storageWarning
        XCTAssertNotNil(warning)
    }
}
