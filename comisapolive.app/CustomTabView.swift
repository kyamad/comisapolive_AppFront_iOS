import SwiftUI

struct CustomTabView: View {
    @StateObject private var tabManager = TabManager()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // コンテンツエリア
                Group {
                    switch tabManager.selectedTab {
                    case 0:
                        HomeView()
                    case 1:
                        ContentView()
                    case 2:
                        SearchView()
                    case 3:
                        MypageView()
                    default:
                        HomeView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // カスタムTabBar
                CustomTabBar(selectedTab: $tabManager.selectedTab)
            }
        }
        .environmentObject(tabManager)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        TabItem(index: 0, customImage: "home", title: "ホーム"),
        TabItem(index: 1, customImage: "menu", title: "カテゴリ"),
        TabItem(index: 2, customImage: "search 1", title: "探す"),
        TabItem(index: 3, customImage: "mypage 1", title: "マイページ")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.index) { tab in
                CustomTabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab.index
                ) {
                    selectedTab = tab.index
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 60) // 標準的なTabBarの高さ
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -2)
    }
}

struct CustomTabBarItem: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(tab.customImage)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .offset(y: 6) // アイコンを6ポイント下に調整
                
                Text(tab.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .offset(y: 10) // テキストを6ポイント下に調整
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TabItem {
    let index: Int
    let customImage: String
    let title: String
}

#Preview {
    CustomTabView()
}
