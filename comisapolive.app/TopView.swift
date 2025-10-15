import SwiftUI

struct TopView: View {
    var body: some View {
        CustomTabView()
    }
}

#if DEBUG
#Preview {
    DebugLiverDataView()
}
#endif
