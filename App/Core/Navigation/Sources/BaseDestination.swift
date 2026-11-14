//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import SwiftUI

/// A screen that can be pushed on the main `NavigationStack`.
///
/// Each feature declares its own subclass inside `extension Destination`, next to the screen,
/// and returns that screen from `getScreen()`. Values the screen needs (an id, a store) are
/// stored properties of the subclass. `MainScreen` never has to know about concrete screens.
///
/// ```swift
/// extension Destination {
///     final class Settings: BaseDestination {
///         override func getScreen() -> any View { SettingsScreen() }
///     }
/// }
///
/// NavController.shared.navigateTo(Destination.Settings())
/// ```
///
/// - Note: Two destinations are equal when their `identity` is equal. It defaults to `route` (the
///   class name); override it in destinations that carry data so different values are not equal.
@MainActor
open class BaseDestination {
    /// The class name. `NavController.popUpTo` is based on it.
    public var route: String {
        String(describing: type(of: self))
    }

    /// What makes two destinations the same screen. Defaults to `route`. Override it in destinations
    /// that carry data (for example an id) so different values are not treated as equal.
    open var identity: AnyHashable {
        route
    }

    public init() {}

    /// The screen to show when this destination is on the stack. Subclasses must override it.
    @ViewBuilder
    open func getScreen() -> any View {
        fatalError("Not implemented!")
    }
}
