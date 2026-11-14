//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

/// Placeholder for a screen with nothing to show (for example no chats yet).
/// For a failed load use `ErrorView`, which adds a retry button.
public struct NoDataView: View {
    private let title: String
    private let message: String
    private let systemImage: String

    public init(title: String, message: String, systemImage: String = "tray") {
        self.title = title
        self.message = message
        self.systemImage = systemImage
    }

    public var body: some View {
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: Text(message)
        )
    }
}

#if DEBUG

#Preview {
    NoDataView(
        title: "No chats",
        message: "Start a new conversation.",
        systemImage: "bubble.left.and.bubble.right"
    )
}

#endif
