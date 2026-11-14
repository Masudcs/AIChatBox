//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import XCTest
@testable import AIChatBox

final class ConversationListViewModelTests: XCTestCase {
    func test_load_whenStoreFails_shouldShowFailureThenRetryRecovers() async {
        let store = FailingConversationStore()
        await store.setShouldFail(true)
        let viewModel = ConversationListViewModel(store: store)

        await viewModel.load()
        guard case .failure(let message) = viewModel.state else { return XCTFail("Expected failure") }
        XCTAssertEqual(message, "The database is unavailable.")

        await store.setShouldFail(false)
        await viewModel.retry()
        guard case .success(let items) = viewModel.state else { return XCTFail("Expected success") }
        XCTAssertTrue(items.isEmpty)
    }

    func test_retry_whenStoreStillDown_shouldStayFailed() async {
        let store = FailingConversationStore()
        await store.setShouldFail(true)
        let viewModel = ConversationListViewModel(store: store)

        await viewModel.retry()

        guard case .failure = viewModel.state else { return XCTFail("Expected failure") }
    }

    func test_makeConversation_whenNoMessageSent_shouldNotBeSaved() async {
        let store = InMemoryConversationStore()
        let viewModel = ConversationListViewModel(store: store)

        let conversation = viewModel.makeConversation()
        await viewModel.load()

        guard case .success(let items) = viewModel.state else { return XCTFail("Expected success") }
        XCTAssertTrue(items.isEmpty)
        XCTAssertTrue(conversation.messages.isEmpty)
    }

    func test_init_whenStoreIsGiven_shouldHaveNoStorageWarning() {
        let viewModel = ConversationListViewModel(store: InMemoryConversationStore())

        XCTAssertNil(viewModel.storageWarning)
    }

    func test_retryStorage_whenDatabaseComesBack_shouldClearWarning() async {
        let disk = StorageSwitch()
        let store = AppConversationStore {
            if disk.isDown { throw StoreError() }
            return try SwiftDataConversationStore.makeContainer(inMemory: true)
        }
        let viewModel = ConversationListViewModel(store: store)

        await viewModel.load()
        XCTAssertNotNil(viewModel.storageWarning)

        disk.isDown = false
        await viewModel.retryStorage()
        XCTAssertNil(viewModel.storageWarning)
    }
}

private final class StorageSwitch: @unchecked Sendable {
    var isDown = true
}
