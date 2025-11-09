import SwiftUI

extension View {
    /// Conditionally applies modifiers that are available on iOS 16 and later.
    @ViewBuilder
    func applyIfAvailableiOS16<Content: View>(
        @ViewBuilder _ transform: (Self) -> Content
    ) -> some View {
        if #available(iOS 16.0, *) {
            transform(self)
        } else {
            self
        }
    }
}