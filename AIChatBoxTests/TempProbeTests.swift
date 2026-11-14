//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import FoundationModels
import XCTest
@testable import AIChatBox

final class TempProbeTests: XCTestCase {
    func test_probe_modelAvailability() async {
        if #available(iOS 26.0, *) {
            NSLog("PROBE availability: %@", String(describing: SystemLanguageModel.default.availability))
        }

        var last = ""
        do {
            for try await text in FoundationModelsChatService.replyStream(to: [ChatMessage(role: .user, text: "Say hi in three words")]) {
                last = text
            }
            NSLog("PROBE reply: %@", last)
        } catch {
            NSLog("PROBE error: %@ | %@", String(describing: type(of: error)), String(describing: error))
        }
    }
}
