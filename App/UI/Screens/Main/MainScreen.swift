//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

/// The root screen. It owns the app's only `NavigationStack`, bound to `NavController.shared`,
/// and shows whatever `BaseDestination` is pushed, so features add screens without changing this file.
struct MainScreen: View {
    @Bindable private var navController = NavController.shared

    var body: some View {
        NavigationStack(path: $navController.navStack) {
            ConversationListScreen()
                .navigationDestination(for: BaseDestination.self) { destination in
                    AnyView(destination.getScreen())
                }
        }
    }
}

#Preview {
    MainScreen()
}
