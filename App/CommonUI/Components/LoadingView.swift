//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

/// Centered spinner shown while a screen loads (`UIState.loading`).
public struct LoadingView: View {
    public init() {}

    public var body: some View {
        ProgressView()
            .controlSize(.large)
    }
}

#if DEBUG

#Preview {
    LoadingView()
}

#endif
