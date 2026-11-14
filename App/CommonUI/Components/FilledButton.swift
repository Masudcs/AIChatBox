//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

/// Full-width prominent button for the main action of a screen.
public struct AppFilledButton: View {
    private let title: String
    private let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
    }
}

#if DEBUG

#Preview {
    AppFilledButton("Continue") {}
        .padding()
}

#endif
