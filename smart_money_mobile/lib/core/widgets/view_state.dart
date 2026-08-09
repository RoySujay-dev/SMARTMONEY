/// Simple UI state model used by the browsing screens.
///
/// The project has no state-management package; screens are plain
/// `StatefulWidget`s driven by `setState`. This enum standardizes the
/// initial/loading/success/empty/error phases those screens move through.
enum ViewState { initial, loading, success, empty, error }
