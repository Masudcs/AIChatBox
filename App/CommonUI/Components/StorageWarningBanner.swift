//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

/// Banner shown when chats are not being saved to disk, with a button to try again.
public struct StorageWarningBanner: View {
    private let message: String
    private let onRetry: () -> Void

    public init(message: String, onRetry: @escaping () -> Void) {
        self.message = message
        self.onRetry = onRetry
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Try again", action: onRetry)
                .font(.footnote.weight(.semibold))
        }
        .padding(8)
        .background(Color.orange.opacity(0.2))
    }
}

#if DEBUG

#Preview {
    StorageWarningBanner(message: "Chats can't be saved on this device right now and will be lost when the app closes.") {}
}

#endif
