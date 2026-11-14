//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation

// `NavigationStack` needs its path values to be `Hashable`. Identity is `identity`: the class name
// unless a destination that carries data overrides it.

extension BaseDestination: @preconcurrency Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }
}

extension BaseDestination: @preconcurrency Equatable {
    public static func == (lhs: BaseDestination, rhs: BaseDestination) -> Bool {
        return lhs.identity == rhs.identity
    }
}
