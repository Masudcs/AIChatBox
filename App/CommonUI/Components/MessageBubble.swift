//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

/// One chat message. The user's bubbles sit on the trailing side and the assistant's on the leading side.
/// `senderName` is shown as a small caption above the bubble when given.
public struct MessageBubble: View {
    private let message: ChatMessage
    private let senderName: String?

    public init(
        message: ChatMessage,
        senderName: String? = nil
    ) {
        self.message = message
        self.senderName = senderName
    }

    private var isUser: Bool { message.role == .user }

    public var body: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 2) {
            if let senderName {
                Text(senderName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }

            Text(message.text)
                // Lines inside the bubble read left to right for both senders; only the bubble itself is pushed to a side.
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundStyle(isUser ? Color.white : Color.primary)
                .background(isUser ? Color.accentColor : Color.secondary.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        // Keeps a minimum gap on the opposite side so long messages never touch the far edge.
        .padding(isUser ? .leading : .trailing, 48)
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }
}

#Preview {
    VStack {
        MessageBubble(
            message: ChatMessage(
                role: .user,
                text: "Hello!"
            ),
            senderName: "You"
        )

        MessageBubble(
            message: ChatMessage(
                role: .assistant,
                text: "Hi, how can I help?"
            ),
            senderName: "Assistant"
        )

        MessageBubble(
            message: ChatMessage(
                role: .user,
                text: "First line\nSecond line is a little longer than the first\nThird"
            ),
            senderName: "You"
        )

        MessageBubble(
            message: ChatMessage(
                role: .assistant,
                text: "Here is a long reply that wraps across several lines so we can check that the bubble stops before the far edge.\n\n1. Point one\n2. Point two"
            ),
            senderName: "Assistant"
        )
    }
    .padding()
}
