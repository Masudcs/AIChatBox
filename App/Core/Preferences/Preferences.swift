//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation

public enum Preferences {
    public static let defaultUserName = "You"
    public static let defaultAssistantName = "Assistant"

    private enum Key {
        static let userName = "preferences.userName"
        static let assistantName = "preferences.assistantName"
    }

    public static var userName: String {
        get { value(for: Key.userName) ?? defaultUserName }
        set { store(newValue, for: Key.userName) }
    }

    public static var assistantName: String {
        get { value(for: Key.assistantName) ?? defaultAssistantName }
        set { store(newValue, for: Key.assistantName) }
    }

    private static func value(for key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }

    /// A blank name clears the stored value, so the default name comes back.
    private static func store(_ name: String, for key: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            UserDefaults.standard.removeObject(forKey: key)
        } else {
            UserDefaults.standard.set(trimmed, forKey: key)
        }
    }
}
