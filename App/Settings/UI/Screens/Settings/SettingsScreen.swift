//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

// MARK: - Destination

extension Destination {
    final class Settings: BaseDestination {
        override func getScreen() -> any View {
            SettingsScreen()
        }
    }
}

// MARK: - UI

/// Edit the names shown in chats. Changes are saved automatically through `Preferences`.
public struct SettingsScreen: View {
    @State private var viewModel: SettingsViewModel

    public init(viewModel: SettingsViewModel? = nil) {
        _viewModel = State(wrappedValue: viewModel ?? SettingsViewModel())
    }

    public var body: some View {
        Form {
            Section {
                TextField(Preferences.defaultUserName, text: $viewModel.userName)
                TextField(Preferences.defaultAssistantName, text: $viewModel.assistantName)
            } header: {
                Text("Names")
            } footer: {
                Text("Shown in chats and shared with the assistant. Leave a field empty to use the default name. Changes are saved automatically.")
            }

            Section("About") {
                LabeledContent("Version", value: AppEnvironment.versionDescription)

                if AppEnvironment.current != .production {
                    LabeledContent("Environment", value: AppEnvironment.current.name)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}

#endif
