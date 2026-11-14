//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import XCTest
@testable import AIChatBox

final class AppEnvironmentTests: XCTestCase {
    func test_current_whenBuiltWithTheSchemesCondition_shouldMatchIt() {
        #if DEVELOPMENT
        XCTAssertEqual(AppEnvironment.current, .development)
        #elseif STAGING
        XCTAssertEqual(AppEnvironment.current, .staging)
        #else
        XCTAssertEqual(AppEnvironment.current, .production)
        #endif
    }

    func test_versionDescription_whenFormatted_shouldShowVersionAndBuild() {
        XCTAssertTrue(AppEnvironment.versionDescription.contains("("))
    }
}
