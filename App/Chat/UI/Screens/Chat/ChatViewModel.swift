//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation
import Observation

/// State and actions for one conversation.
///
/// `send()` appends the user's message and saves it, then streams the reply from `IChatRepository`
/// and saves again. If the reply fails, `errorMessage` is set, the user's message is kept, and
/// `retry()` can ask again. The title of a new conversation is the first 40 characters of the
/// first message.
@MainActor
@Observable
public final class ChatViewModel {
    private(set) var conversation: Conversation
    private(set) var isReplying = false
    private(set) var errorMessage: String?

    /// Set while chats are not being saved to disk.
    private(set) var storageWarning: String?

    var draft = ""

    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isReplying
    }

    private let repository: IChatRepository
    private let store: IConversationStore

    public init(
        conversation: Conversation,
        repository: IChatRepository = ChatRepository(),
        store: IConversationStore
    ) {
        self.conversation = conversation
        self.repository = repository
        self.store = store
    }

    /// The last message is the user's, so no reply was received: it failed or the app was closed
    /// while waiting. `retry()` asks for the reply again.
    var canRetry: Bool {
        !isReplying && conversation.messages.last?.role == .user
    }

    func send() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isReplying else { return }

        draft = ""
        errorMessage = nil
        isReplying = true
        conversation.messages.append(ChatMessage(role: .user, text: text))

        if conversation.messages.count == 1 {
            conversation.title = String(text.prefix(40))
        }

        // Saved before waiting for the reply, so the message survives if the app is closed meanwhile.
        await save()
        await requestReply()
    }

    /// Asks again for the reply to the last user message.
    func retry() async {
        guard canRetry else { return }

        errorMessage = nil
        isReplying = true
        await requestReply()
    }

    /// Shows the reply as it streams in: the assistant message is added on the first piece of text
    /// and then grows. A partial reply is kept if the stream fails.
    private func requestReply() async {
        let history = conversation.messages
        var replyIndex: Int?

        do {
            for try await text in repository.replyStream(to: history) {
                if let index = replyIndex {
                    conversation.messages[index].text = text
                } else {
                    conversation.messages.append(ChatMessage(role: .assistant, text: text))
                    replyIndex = conversation.messages.count - 1
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isReplying = false
        await save()
    }

    func refreshStorageWarning() async {
        storageWarning = await store.storageWarning
    }

    /// Tries the on-disk database again and saves this chat to it if that works.
    func retryStorage() async {
        if await store.reopenStorage() {
            await save()
        }

        await refreshStorageWarning()
    }

    private func save() async {
        conversation.updatedAt = .now

        do {
            try await store.save(conversation)
        } catch {
            // Keep an existing error; a reply error is the more useful message.
            errorMessage = errorMessage ?? "Couldn't save this chat. \(error.localizedDescription)"
        }

        await refreshStorageWarning()
    }
}

#if DEBUG

extension ChatViewModel {
    convenience init(
        isReplying: Bool = false,
        isError: Bool = false,
        isEmpty: Bool = false,
        isStorageWarning: Bool = false
    ) {
        var conversation = isEmpty
            ? Conversation(title: "New chat")
            : Conversation.mockList()[0]

        // A reply that is still loading, or that failed, follows a message from the user.
        if isReplying || isError {
            conversation.messages.append(ChatMessage(role: .user, text: "Tell me more"))
        }

        self.init(conversation: conversation, store: InMemoryConversationStore())

        self.isReplying = isReplying
        if isStorageWarning {
            self.storageWarning = "Chats can't be saved on this device right now and will be lost when the app closes."
        }
        if isError {
            self.errorMessage = "On-device AI is unavailable: Apple Intelligence is not enabled."
        }
    }
}

#endif
