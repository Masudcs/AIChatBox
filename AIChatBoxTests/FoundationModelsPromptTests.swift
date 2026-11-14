//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import XCTest
@testable import AIChatBox

final class FoundationModelsPromptTests: XCTestCase {
    private func history(_ texts: [String]) -> [ChatMessage] {
        texts.enumerated().map { index, text in
            ChatMessage(role: index.isMultiple(of: 2) ? .user : .assistant, text: text)
        }
    }

    func test_prompt_whenNoHistory_shouldContainOnlyLatestMessage() {
        XCTAssertEqual(FoundationModelsChatService.prompt(from: history(["hello"])), "hello")
    }

    func test_prompt_whenHistoryFits_shouldIncludeEarlierMessagesInOrder() {
        let prompt = FoundationModelsChatService.prompt(from: history(["one", "two", "three"]))

        XCTAssertTrue(prompt.contains("User: one\nAssistant: two"))
        XCTAssertTrue(prompt.hasSuffix("three"))
    }

    func test_prompt_whenOverBudget_shouldDropOldestFirst() {
        // Budget fits only the newest earlier message ("bbbbb"), not "aaaaa" as well.
        let prompt = FoundationModelsChatService.prompt(
            from: history(["aaaaa", "bbbbb", "latest"]),
            characterBudget: 7
        )

        XCTAssertFalse(prompt.contains("aaaaa"))
        XCTAssertTrue(prompt.contains("bbbbb"))
        XCTAssertTrue(prompt.hasSuffix("latest"))
    }

    func test_prompt_whenBudgetIsZero_shouldContainOnlyLatestMessage() {
        let prompt = FoundationModelsChatService.prompt(
            from: history(["old", "older reply", "latest"]),
            characterBudget: 0
        )

        XCTAssertEqual(prompt, "latest")
    }

    func test_characterBudgets_whenListed_shouldShrinkToZero() {
        XCTAssertEqual(FoundationModelsChatService.characterBudgets.last, 0)
        XCTAssertEqual(FoundationModelsChatService.characterBudgets, FoundationModelsChatService.characterBudgets.sorted(by: >))
    }
}
