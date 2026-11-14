//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Observation

/// Holds the two names being edited and writes each change straight to `Preferences`.
@MainActor
@Observable
public final class SettingsViewModel {
    var userName: String { didSet { Preferences.userName = userName } }
    var assistantName: String { didSet { Preferences.assistantName = assistantName } }

    public init() {
        userName = Preferences.userName
        assistantName = Preferences.assistantName
    }
}
