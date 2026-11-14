//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import XCTest
@testable import AIChatBox

private struct StubRepository: IChatRepository {
    func reply(to history: [ChatMessage]) async throws -> ChatMessage {
        ChatMessage(role: .assistant, text: "pong")
    }
}

@MainActor
final class ChatViewModelTests: XCTestCase {
    func test_send_whenDraftHasText_shouldAppendUserAndAssistantMessages() async {
        let conversation = Conversation(title: "New chat")
        let store = InMemoryConversationStore(seed: [conversation])
        let viewModel = ChatViewModel(conversation: conversation, repository: StubRepository(), store: store)

        viewModel.draft = "ping"
        await viewModel.send()

        XCTAssertEqual(viewModel.conversation.messages.map(\.text), ["ping", "pong"])
        XCTAssertEqual(viewModel.conversation.title, "ping")
        let saved = await store.conversation(id: conversation.id)
        XCTAssertEqual(saved?.messages.count, 2)
    }

    func test_send_whenDraftIsBlank_shouldIgnoreIt() async {
        let conversation = Conversation(title: "New chat")
        let viewModel = ChatViewModel(
            conversation: conversation,
            repository: StubRepository(),
            store: InMemoryConversationStore()
        )
        viewModel.draft = "   "
        await viewModel.send()
        XCTAssertTrue(viewModel.conversation.messages.isEmpty)
    }

    func test_send_whenSaveFails_shouldShowErrorAndKeepMessages() async {
        let conversation = Conversation(title: "New chat")
        let store = FailingConversationStore()
        await store.setShouldFail(true)
        let viewModel = ChatViewModel(conversation: conversation, repository: StubRepository(), store: store)

        viewModel.draft = "ping"
        await viewModel.send()

        XCTAssertEqual(viewModel.conversation.messages.map(\.text), ["ping", "pong"])
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func test_send_whenReplyIsPending_shouldAlreadyHaveSavedUserMessage() async {
        let conversation = Conversation(title: "New chat")
        let store = InMemoryConversationStore()
        let repository = SlowRepository()
        let viewModel = ChatViewModel(conversation: conversation, repository: repository, store: store)

        viewModel.draft = "hello"
        let sending = Task { await viewModel.send() }

        // Wait until the repository is asked for the reply, which happens after the first save.
        await repository.waitUntilReplying()
        let saved = await store.conversation(id: conversation.id)
        XCTAssertEqual(saved?.messages.map(\.text), ["hello"])

        await repository.finish("done")
        await sending.value
        let final = await store.conversation(id: conversation.id)
        XCTAssertEqual(final?.messages.map(\.text), ["hello", "done"])
    }

    func test_send_whenReplyStreams_shouldEndWithOneAssistantMessage() async {
        let viewModel = ChatViewModel(
            conversation: Conversation(title: "New chat"),
            repository: StreamingRepository(pieces: ["Hel", "Hello", "Hello there"]),
            store: InMemoryConversationStore()
        )

        viewModel.draft = "hi"
        await viewModel.send()

        XCTAssertEqual(viewModel.conversation.messages.map(\.text), ["hi", "Hello there"])
        XCTAssertFalse(viewModel.canRetry)
    }

    func test_retry_whenReplyFailed_shouldRequestReplyAgain() async {
        let repository = FlakyRepository()
        let viewModel = ChatViewModel(
            conversation: Conversation(title: "New chat"),
            repository: repository,
            store: InMemoryConversationStore()
        )

        viewModel.draft = "hi"
        await viewModel.send()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.canRetry)
        XCTAssertEqual(viewModel.conversation.messages.map(\.text), ["hi"])

        await repository.setShouldFail(false)
        await viewModel.retry()

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.canRetry)
        XCTAssertEqual(viewModel.conversation.messages.map(\.text), ["hi", "pong"])
    }
}

private struct StreamingRepository: IChatRepository {
    let pieces: [String]

    func reply(to history: [ChatMessage]) async throws -> ChatMessage {
        ChatMessage(role: .assistant, text: pieces.last ?? "")
    }

    func replyStream(to history: [ChatMessage]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            pieces.forEach { continuation.yield($0) }
            continuation.finish()
        }
    }
}

/// Fails until `setShouldFail(false)` is called.
private actor FlakyRepository: IChatRepository {
    private var shouldFail = true

    func setShouldFail(_ value: Bool) {
        shouldFail = value
    }

    func reply(to history: [ChatMessage]) async throws -> ChatMessage {
        if shouldFail { throw StoreError() }
        return ChatMessage(role: .assistant, text: "pong")
    }
}

/// Holds the reply until `finish(_:)` is called, so a test can look at the state in between.
private actor SlowRepository: IChatRepository {
    private var isWaiting = false
    private var reply: CheckedContinuation<String, Never>?

    func reply(to history: [ChatMessage]) async throws -> ChatMessage {
        isWaiting = true
        let text = await withCheckedContinuation { reply = $0 }
        return ChatMessage(role: .assistant, text: text)
    }

    func waitUntilReplying() async {
        while !isWaiting { await Task.yield() }
    }

    func finish(_ text: String) {
        reply?.resume(returning: text)
        reply = nil
    }
}
