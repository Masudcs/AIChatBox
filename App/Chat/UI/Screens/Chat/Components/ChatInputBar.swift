//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

/// Text field and send button at the bottom of the chat. The button is disabled when `canSend` is false.
struct ChatInputBar: View {
    @Binding var text: String
    let canSend: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Message", text: $text, axis: .vertical)
                .lineLimit(1...5)
                .textFieldStyle(.roundedBorder)
                .onSubmit(onSend)

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill").font(.system(size: 32))
            }
            .disabled(!canSend)
        }
        .padding()
        .background(.bar)
    }
}

#if DEBUG

struct ChatInputBar_Previews: PreviewProvider {
    static var previews: some View {
        ChatInputBar(text: .constant(""), canSend: false, onSend: {})
            .previewDisplayName("Empty")

        ChatInputBar(text: .constant("Hello there"), canSend: true, onSend: {})
            .previewDisplayName("Can send")
    }
}

#endif
