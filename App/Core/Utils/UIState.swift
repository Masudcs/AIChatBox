//
//  Copyright © 2026 Md. Masud Rana. All rights reserved.
//

import Foundation

/// What a screen is currently showing for data it loads.
///
/// - `loading`: show `LoadingView`.
/// - `success`: show the data, or `NoDataView` if it is empty.
/// - `failure`: show `ErrorView` with the message and a retry action.
public enum UIState<Value> {
    case loading
    case success(Value)
    case failure(String)
}
