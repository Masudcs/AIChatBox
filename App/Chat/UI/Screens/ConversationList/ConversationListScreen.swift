//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

/// The root screen: all conversations, newest first, with swipe to delete.
/// The toolbar starts a new chat or opens Settings. Loading, error and empty states use
/// `LoadingView`, `ErrorView` and `NoDataView`.
public struct ConversationListScreen: View {
    @State private var viewModel: ConversationListViewModel

    public init(viewModel: ConversationListViewModel = ConversationListViewModel()) {
        _viewModel = State(wrappedValue: viewModel)
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                LoadingView()
                
            case .failure(let message):
                ErrorView(message: message) {
                    Task { await viewModel.retry() }
                }
                
            case .success(let conversations) where conversations.isEmpty:
                NoDataView(
                    title: "No chats",
                    message: "Start a new conversation.",
                    systemImage: "bubble.left.and.bubble.right"
                )
                
            case .success(let conversations):
                List {
                    ForEach(conversations) { conversation in
                        Button {
                            NavController.shared.navigateTo(
                                Destination.Chat(
                                    id: conversation.id,
                                    store: viewModel.store
                                )
                            )
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(conversation.title)
                                    .font(.headline)
                                
                                Text(conversation.lastMessagePreview)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            // Without these only the text itself is tappable, not the empty space beside it.
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        let ids = offsets.map { conversations[$0].id }
                        
                        Task {
                            for id in ids {
                                await viewModel.delete(id: id)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .top, spacing: 0) {
            if let warning = viewModel.storageWarning {
                StorageWarningBanner(message: warning) {
                    Task { await viewModel.retryStorage() }
                }
            }
        }
        .navigationTitle("AI ChatBox")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New chat", systemImage: "square.and.pencil") {
                    NavController.shared.navigateTo(
                        Destination.Chat(
                            conversation: viewModel.makeConversation(),
                            store: viewModel.store
                        )
                    )
                }
            }
            
            ToolbarItem(placement: .navigation) {
                Button("Settings", systemImage: "gearshape") {
                    NavController.shared.navigateTo(Destination.Settings())
                }
            }
        }
        .task { await viewModel.load() }
    }
}

// MARK: - Previews

#if DEBUG

struct ConversationListScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ConversationListScreen(viewModel: ConversationListViewModel(isPreview: true))
        }
        .previewDisplayName("Data")

        NavigationStack {
            ConversationListScreen(
                viewModel: ConversationListViewModel(
                    isPreview: true,
                    isLoading: true
                )
            )
        }
        .previewDisplayName("Loading")

        NavigationStack {
            ConversationListScreen(
                viewModel: ConversationListViewModel(
                    isPreview: true,
                    isError: true
                )
            )
        }
        .previewDisplayName("Error")

        NavigationStack {
            ConversationListScreen(
                viewModel: ConversationListViewModel(
                    isPreview: true,
                    isEmpty: true
                )
            )
        }
        .previewDisplayName("Empty")

        NavigationStack {
            ConversationListScreen(
                viewModel: ConversationListViewModel(
                    isPreview: true,
                    isStorageWarning: true
                )
            )
        }
        .previewDisplayName("Storage warning")
    }
}

#endif
