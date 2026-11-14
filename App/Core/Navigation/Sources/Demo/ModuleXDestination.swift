//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

#if DEBUG

extension Destination {
    final class A: BaseDestination {
        override func getScreen() -> any View {
            NavigationDemoScreen(route)
        }
    }

    final class B: BaseDestination {
        override func getScreen() -> any View {
            NavigationDemoScreen(route)
        }
    }
}

#endif
