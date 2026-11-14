//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

#if DEBUG

extension Destination {
    final class C: BaseDestination {
        let id: Int

        public init(id: Int) {
            self.id = id
        }

        override func getScreen() -> any View {
            NavigationDemoScreen("\(route) (\(id))")
        }
    }
}

#endif
