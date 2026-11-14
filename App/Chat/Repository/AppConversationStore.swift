//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation
import SwiftData

/// The store the app uses. It saves to the on-disk SwiftData database.
///
/// If that database can't be opened, it keeps working in memory so the app is still usable, and
/// sets `storageWarning` because those chats are lost when the app closes. `reopenStorage()` tries
/// the database again and, when it opens, moves the chats made in the meantime into it.
public actor AppConversationStore: IConversationStore {
    public static let shared = AppConversationStore()

    private let openDisk: @Sendable () throws -> ModelContainer
    private var store: IConversationStore
    private var warning: String?

    public init(
        openDisk: @escaping @Sendable () throws -> ModelContainer = {
            try SwiftDataConversationStore.makeContainer()
        }
    ) {
        self.openDisk = openDisk

        do {
            store = SwiftDataConversationStore(modelContainer: try openDisk())
        } catch {
            guard let container = try? SwiftDataConversationStore.makeContainer(inMemory: true) else {
                fatalError("Unable to create the SwiftData container: \(error)")
            }

            store = SwiftDataConversationStore(modelContainer: container)
            warning = Self.warning(for: error)
        }
    }

    public var storageWarning: String? {
        warning
    }

    public func reopenStorage() async -> Bool {
        guard warning != nil else { return true }

        do {
            let disk = SwiftDataConversationStore(modelContainer: try openDisk())

            for conversation in try await store.conversations() {
                try await disk.save(conversation)
            }

            store = disk
            warning = nil
            return true
        } catch {
            warning = Self.warning(for: error)
            return false
        }
    }

    public func conversations() async throws -> [Conversation] {
        try await store.conversations()
    }

    public func conversation(id: UUID) async throws -> Conversation? {
        try await store.conversation(id: id)
    }

    public func save(_ conversation: Conversation) async throws {
        try await store.save(conversation)
    }

    public func delete(id: UUID) async throws {
        try await store.delete(id: id)
    }

    private static func warning(for error: Error) -> String {
        "Chats can't be saved on this device right now and will be lost when the app closes. \(error.localizedDescription)"
    }
}
