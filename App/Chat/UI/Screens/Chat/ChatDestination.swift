//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

extension Destination {
    final class Chat: BaseDestination {
        private let id: UUID
        private let store: IConversationStore
        /// Set for a chat that has not been saved yet; it is shown without reading the store.
        private let newConversation: Conversation?

        /// Opens a saved conversation.
        init(id: UUID, store: IConversationStore) {
            self.id = id
            self.store = store
            self.newConversation = nil
        }

        /// Opens a new conversation that is saved when its first message is sent.
        init(conversation: Conversation, store: IConversationStore) {
            self.id = conversation.id
            self.store = store
            self.newConversation = conversation
        }

        override var identity: AnyHashable {
            [route, id.uuidString]
        }

        override func getScreen() -> any View {
            ChatLoaderView(id: id, store: store, newConversation: newConversation)
        }
    }
}

/// Loads the conversation asynchronously, then shows the chat screen.
private struct ChatLoaderView: View {
    let id: UUID
    let store: IConversationStore
    var newConversation: Conversation?

    @State private var state: UIState<Conversation?> = .loading

    var body: some View {
        ZStack {
            switch state {
            case .loading:
                LoadingView()

            case .failure(let message):
                ErrorView(message: message) {
                    Task { await load() }
                }

            case .success(.none):
                NoDataView(
                    title: "Chat not found",
                    message: "This conversation no longer exists.",
                    systemImage: "bubble.left.and.bubble.right"
                )

            case .success(.some(let conversation)):
                ChatScreen(
                    viewModel: ChatViewModel(conversation: conversation, store: store)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            // Do not reload a chat that is already showing; that would drop an unsaved new chat.
            if case .success = state { return }
            await load()
        }
    }

    private func load() async {
        if let newConversation {
            state = .success(newConversation)
            return
        }

        state = .loading

        do {
            state = .success(try await store.conversation(id: id))
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
}

#if DEBUG

struct ChatLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        let conversation = Conversation.mockList()[0]

        NavigationStack {
            ChatLoaderView(id: conversation.id, store: InMemoryConversationStore(seed: [conversation]))
        }
        .previewDisplayName("Loaded")

        NavigationStack {
            ChatLoaderView(id: UUID(), store: InMemoryConversationStore())
        }
        .previewDisplayName("Not found")
    }
}

#endif
