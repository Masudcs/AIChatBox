# AIChatBox

SwiftUI iOS chat app. A single app target organised by feature folders (like Apple's Landmarks sample): no packages and no extra frameworks. Chats are saved with SwiftData and replies come from Apple's on-device Foundation Models.

## Project layout

```
App/
  AIChatBoxApp.swift  Entry point
  UI/Screens/Main/    MainScreen: the root NavigationStack
  Core/               Models, navigation (NavController, BaseDestination), protocols, preferences, UIState, SuperLog
  CommonUI/           Reusable SwiftUI components (MessageBubble, ErrorView, NoDataView, LoadingView, AppFilledButton)
  Chat/               Conversation list + chat (UI/Screens, Repository)
  Settings/           Settings screen (user and assistant names)
  Resources/          Assets
AIChatBoxTests/       Unit tests (@testable import AIChatBox)
AIChatBox.xcodeproj
```

There is no module boundary, so any file can use any other. Keep dependencies pointing the same way as a module setup would: features (`Chat`, `Settings`) use `Core` and `CommonUI`, never each other.

## How it works

### Navigation

- `MainScreen` owns one `NavigationStack` bound to `NavController.shared.navStack`, with a single `.navigationDestination(for: BaseDestination.self)` that calls `destination.getScreen()`. It has no `switch` over screens.
- Every pushable screen is a `BaseDestination` subclass declared as `extension Destination { final class Name: BaseDestination { ... } }`, next to its screen, and returns that screen from `getScreen()`. Parameters (an id, a store) are stored properties of the destination.
- To open a screen: `NavController.shared.navigateTo(Destination.Chat(id: id, store: store))`. Other helpers: `popBackStack()`, `popUpTo(_:)`, `popUpToRoot()`.
- To add a screen, add its destination next to it. `MainScreen` does not change.

### Screens and view models

- Each screen has an `@Observable` view model. Screens take an optional view model (`viewModel: X? = nil`) so previews and tests can inject one.
- Loading state is `UIState<Value>` (`.loading`, `.success`, `.failure(String)`). Show `.failure` with `ErrorView` and a retry callback, and an empty result with `NoDataView`.

### Data

- Conversations go through the `IConversationStore` protocol. The app uses `AppConversationStore.shared`, which saves to disk with SwiftData (`SwiftDataConversationStore`). `InMemoryConversationStore` is for tests and previews.
- If the on-disk database cannot be opened, `AppConversationStore` keeps working in memory and sets `storageWarning`. The chat list and chat screens show a banner with a Try again button; when the database opens, the chats made in the meantime are moved into it.
- The store methods throw. A failed load shows `UIState.failure` with a Retry button, the chat loader shows an `ErrorView`, and a failed save in a chat shows an error message while the messages stay on screen.
- `ConversationListViewModel` creates the one store for the chat feature and hands it to the screens it opens, so the list and the chat see the same data.

### Chat replies

- `ChatRepository.reply(to:)` calls `FoundationModelsChatService`, which uses Apple's on-device model (iOS 26 and later, Apple Intelligence enabled). It is free and needs no API key.
- If the model cannot be used, the repository throws a `ChatError` and the chat screen shows the message. There is no fallback reply.
- The user and assistant names from Settings (`Preferences`) are shown above messages and included in the model instructions.

### Previews

Following ART4: each view model has a `#if DEBUG` convenience init (for example `isLoading:`, `isError:`, `isEmpty:`) that sets a fixed state using an in-memory store, and an `isPreview` flag so `load()` does not replace it. Each screen file ends with a `PreviewProvider` listing one preview per state.

## Environments

Three environments are set up as Xcode schemes, each with its own build configurations, `xcconfig` file and bundle identifier, so they can be installed side by side:

| Scheme | Configurations | App name | Bundle ID | Condition |
|---|---|---|---|---|
| `AIChat-DEV` | Debug / Release Development | AIChat DEV | `com.example.AIChatBox-dev` | `DEVELOPMENT` |
| `AIChat-Staging` | Debug / Release Staging | AIChat UAT | `com.example.AIChatBox-uat` | `STAGING` |
| `AIChat-Production` | Debug / Release Production | AIChat | `com.example.AIChatBox` | `PRODUCTION` |

- `ConfigurationFiles/<Environment>.xcconfig` sets the app version (`XCC_APP_VERSION`), build number (`XCC_APP_BUILD`) and display name (`XCC_PRODUCT_NAME`). Change a version there, not in the project.
- In code, `AppEnvironment.current` tells which environment the build is for. Settings > About shows the version, and the environment for non-production builds.
- To add an environment-specific value (for example an API URL), add it to the three xcconfig files, then read it from `Info.plist` or switch on `AppEnvironment.current`.

## Running and testing

Open `AIChatBox.xcodeproj`, pick a scheme and run, or:

```bash
xcodebuild test -scheme AIChat-DEV -destination 'platform=iOS Simulator,name=<device>'
```

Real chat replies need a simulator or device with Apple Intelligence available.

## Known issues

- Replies arrive all at once; there is no streaming.
- `Core/Navigation/Sources/Demo/` is sample code and can be deleted.
