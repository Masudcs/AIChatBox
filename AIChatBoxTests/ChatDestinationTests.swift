//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import XCTest
@testable import AIChatBox

@MainActor
final class ChatDestinationTests: XCTestCase {
    private let store = InMemoryConversationStore()

    func test_equality_whenSameConversationId_shouldBeEqual() {
        let id = UUID()
        let first = Destination.Chat(id: id, store: store)
        let second = Destination.Chat(id: id, store: store)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.hashValue, second.hashValue)
    }

    func test_equality_whenDifferentConversationIds_shouldNotBeEqual() {
        XCTAssertNotEqual(
            Destination.Chat(id: UUID(), store: store),
            Destination.Chat(id: UUID(), store: store)
        )
    }

    func test_equality_whenDestinationsHaveNoData_shouldCompareByType() {
        XCTAssertEqual(Destination.Settings(), Destination.Settings())
        XCTAssertNotEqual(
            Destination.Settings() as BaseDestination,
            Destination.Chat(id: UUID(), store: store)
        )
    }
}
