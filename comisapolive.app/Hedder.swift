import SwiftUI

struct Header: View {
    @EnvironmentObject var tabManager: TabManager
    private let dynamicHeight: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .frame(height: 1)
                .background(Color.white)
            
            Divider()
                .frame(height: 3)
                .background(Color.black)

            HStack {
                NavigationLink(destination: ContentView()) {
                    Image("title")
                        .resizable()
                        .scaledToFit() // アスペクト比を維持
                        .frame(width: dynamicHeight * 3)
                        .padding(.leading, 13)
                }



                Spacer()

                Button(action: {
                    tabManager.selectedTab = 2 // SearchViewのタブに切り替え
                }) {
                    Image("Search")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                }
                .padding(.trailing, 16)
            }
            .frame(height: dynamicHeight)

            Divider()
                .frame(height: 3)
                .background(Color.black)
        }
        .background(Color.white)
    }
}

#Preview {
    Header()
        .environmentObject(TabManager())
}
