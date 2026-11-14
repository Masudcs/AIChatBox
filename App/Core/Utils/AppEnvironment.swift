//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation

/// Which backend and settings this build is for. It is chosen by the Xcode scheme:
/// `AIChat-DEV`, `AIChat-Staging` or `AIChat-Production`. Each scheme builds with its own
/// configuration (for example "Debug Staging"), xcconfig file and compilation condition.
public enum AppEnvironment: String, CaseIterable {
    case development = "Development"
    case staging = "Staging"
    case production = "Production"

    public static var current: AppEnvironment {
        #if DEVELOPMENT
        .development
        #elseif STAGING
        .staging
        #else
        .production
        #endif
    }

    public var name: String {
        rawValue
    }

    /// "1.0 (1)", from the version and build number set in the environment's xcconfig file.
    public static var versionDescription: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }
}
