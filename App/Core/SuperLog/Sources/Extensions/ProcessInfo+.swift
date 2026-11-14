//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation

extension ProcessInfo {
    /// - Returns: `true` is the code is running from preview.
    var isSwiftUIPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
