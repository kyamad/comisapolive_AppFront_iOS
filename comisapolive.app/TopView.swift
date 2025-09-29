import SwiftUI

struct TopView: View {
    var body: some View {
        CustomTabView()
    }
}

extension View {
    func navigationStack() -> some View {
        NavigationStack {
            self
        }
    }
}

#Preview {
    DebugLiverDataView()
}
