//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

/// Placeholder for a failed load, with a Retry button that calls `onRetry`.
/// For an empty result that is not an error use `NoDataView`.
public struct ErrorView: View {
    private let title: String
    private let message: String
    private let onRetry: () -> Void

    public init(
        title: String = "Something went wrong",
        message: String,
        onRetry: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.onRetry = onRetry
    }

    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
    }
}

#if DEBUG

#Preview {
    ErrorView(message: "Something went wrong. Please retry.") {}
}

#endif
