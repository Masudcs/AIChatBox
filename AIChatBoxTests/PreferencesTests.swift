//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import XCTest
@testable import AIChatBox

final class PreferencesTests: XCTestCase {
    override func tearDown() {
        Preferences.userName = ""
        Preferences.assistantName = ""
        super.tearDown()
    }

    func test_userName_whenSetToBlank_shouldFallBackToDefault() {
        Preferences.userName = "Masud"
        XCTAssertEqual(Preferences.userName, "Masud")

        Preferences.userName = "   "
        XCTAssertEqual(Preferences.userName, Preferences.defaultUserName)
    }

    func test_assistantName_whenSetWithWhitespace_shouldBeTrimmed() {
        Preferences.assistantName = "  Nova \n"
        XCTAssertEqual(Preferences.assistantName, "Nova")
    }
}
