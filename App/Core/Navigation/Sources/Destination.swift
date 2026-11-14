//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation

public enum Destination {}

// MARK: - Default Root Destination

public extension Destination {
    /// A dummy destination for root screen. Don't pass this to any method in the `NavController`.
    final class Root: BaseDestination {}
}
