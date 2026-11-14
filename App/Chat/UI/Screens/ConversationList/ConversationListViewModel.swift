//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation
import Observation

@Observable
public class ConversationListViewModel {
    private(set) var state: UIState<[Conversation]> = .loading

    /// Single store for the whole chat feature; the screens it opens receive it from here.
    let store: IConversationStore

    /// Shown above the list when chats can't be saved to disk.
    private(set) var storageWarning: String?

    /// Previews set a fixed state, so `load()` must not replace it.
    private var isPreview = false

    /// Uses the app's store unless another one is given.
    public init(store: IConversationStore? = nil) {
        self.store = store ?? AppConversationStore.shared
    }

    func load() async {
        guard !isPreview else { return }

        do {
            state = .success(try await store.conversations())
        } catch {
            state = .failure(error.localizedDescription)
        }

        storageWarning = await store.storageWarning
    }

    /// Shows the loading state again, then reloads. Used by the error view's retry button.
    func retry() async {
        guard !isPreview else { return }

        state = .loading
        await load()
    }

    /// Tries the on-disk database again; the list is reloaded from it if that works.
    func retryStorage() async {
        guard !isPreview else { return }

        _ = await store.reopenStorage()
        await load()
    }

    /// A new, empty conversation. It is not saved here: `ChatViewModel` saves it with the first
    /// message, so leaving the chat without typing leaves no empty "New chat" behind.
    func makeConversation() -> Conversation {
        Conversation(title: "New chat")
    }

    func delete(id: UUID) async {
        do {
            try await store.delete(id: id)
        } catch {
            state = .failure("Couldn't delete the chat. \(error.localizedDescription)")
            return
        }

        await load()
    }
}

#if DEBUG

extension ConversationListViewModel {
    convenience init(
        isPreview: Bool = true,
        isLoading: Bool = false,
        isError: Bool = false,
        isEmpty: Bool = false,
        isStorageWarning: Bool = false
    ) {
        // In-memory store, so previews never open the real database.
        self.init(store: InMemoryConversationStore())

        self.isPreview = isPreview

        if isStorageWarning {
            storageWarning = "Chats can't be saved on this device right now and will be lost when the app closes."
        }

        if isLoading {
            state = .loading
        } else if isError {
            state = .failure("Something went wrong. Please retry.")
        } else if isEmpty {
            state = .success([])
        } else {
            state = .success(Conversation.mockList())
        }
    }
}

#endif
