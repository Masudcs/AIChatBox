//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import XCTest
@testable import AIChatBox

final class ConversationTests: XCTestCase {
    func test_lastMessagePreview_whenNoMessages_shouldFallBack() {
        XCTAssertEqual(Conversation(title: "New").lastMessagePreview, "No messages yet")
    }

    func test_lastMessagePreview_whenHasMessages_shouldUseLastMessage() {
        let conversation = Conversation(
            title: "Hi",
            messages: [ChatMessage(role: .user, text: "a"), ChatMessage(role: .assistant, text: "b")]
        )
        XCTAssertEqual(conversation.lastMessagePreview, "b")
    }
}
