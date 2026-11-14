//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

/// The messages of one conversation with the input bar. Scrolls to the newest message and shows
/// `viewModel.errorMessage` above the input bar when a reply fails.
public struct ChatScreen: View {
    @State private var viewModel: ChatViewModel

    public init(viewModel: ChatViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    // MARK: - Helpers

    private func senderName(for message: ChatMessage) -> String {
        message.role == .user ? Preferences.userName : Preferences.assistantName
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            if let warning = viewModel.storageWarning {
                StorageWarningBanner(message: warning) {
                    Task { await viewModel.retryStorage() }
                }
            }

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.conversation.messages) { message in
                            MessageBubble(message: message, senderName: senderName(for: message))
                                .id(message.id)
                        }
                        
                        if viewModel.isReplying, viewModel.conversation.messages.last?.role == .user {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.conversation.messages.count) {
                    if let last = viewModel.conversation.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                // Follows the reply while it streams in.
                .onChange(of: viewModel.conversation.messages.last?.text) {
                    if let last = viewModel.conversation.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            if viewModel.errorMessage != nil || viewModel.canRetry {
                HStack {
                    if let error = viewModel.errorMessage {
                        Text(error).font(.footnote).foregroundStyle(.red)
                    }

                    Spacer()

                    if viewModel.canRetry {
                        Button("Retry reply") {
                            Task { await viewModel.retry() }
                        }
                        .font(.footnote)
                    }
                }
                .padding(.horizontal)
            }

            ChatInputBar(
                text: $viewModel.draft,
                canSend: viewModel.canSend,
                onSend: { Task { await viewModel.send() } }
            )
        }
        .task { await viewModel.refreshStorageWarning() }
        .navigationTitle(viewModel.conversation.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Previews

#if DEBUG

struct ChatScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChatScreen(viewModel: ChatViewModel())
        }
        .previewDisplayName("Messages")

        NavigationStack {
            ChatScreen(viewModel: ChatViewModel(isReplying: true))
        }
        .previewDisplayName("Replying")

        NavigationStack {
            ChatScreen(viewModel: ChatViewModel(isError: true))
        }
        .previewDisplayName("Error")

        NavigationStack {
            ChatScreen(viewModel: ChatViewModel(isEmpty: true))
        }
        .previewDisplayName("Empty")

        NavigationStack {
            ChatScreen(viewModel: ChatViewModel(isStorageWarning: true))
        }
        .previewDisplayName("Storage warning")
    }
}

#endif
