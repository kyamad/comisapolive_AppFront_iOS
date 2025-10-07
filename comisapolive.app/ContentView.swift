import SwiftUI

// ジャンルデータ構造
struct Genre: Identifiable {
    let id = UUID()
    let imageName: String
    let name: String
}

struct ContentView: View {
    @State private var selectedTab: Int = 0 // ✅ 選択中のタブを管理
    @State private var selectedPlatform: String? = nil
    @State private var isShowingDetail: Bool = false // ✅ 詳細画面の表示状態を管理
    @State private var selectedLiver: Liver? = nil
    @StateObject private var apiClient = LiverAPIClient()
    @StateObject private var reviewStatsStore = ReviewStatsStore()
    
    // ジャンル一覧データ
    private let genres = [
        Genre(imageName: "zatudan", name: "雑談"),
        Genre(imageName: "uta", name: "歌配信"),
        Genre(imageName: "ongaku", name: "音楽（楽器）"),
        Genre(imageName: "owarai", name: "コメディ・お笑い"),
        Genre(imageName: "cosplay", name: "コスプレ"),
        Genre(imageName: "uranai", name: "占い"),
        Genre(imageName: "cooking", name: "料理"),
        Genre(imageName: "art", name: "アート"),
        Genre(imageName: "training", name: "トレーニング"),
        Genre(imageName: "radio", name: "ラジオ"),
        Genre(imageName: "model", name: "モデル"),
        Genre(imageName: "soudan", name: "お悩み相談"),
        Genre(imageName: "game", name: "ゲーム配信"),
        Genre(imageName: "vliver", name: "Vライバー"),
        Genre(imageName: "vstreamer", name: "バーチャルストリーマー"),
        Genre(imageName: "streamer", name: "ストリーマー"),
        Genre(imageName: "fps", name: "ストリーマー(FPS)"),
        Genre(imageName: "kojin", name: "ストリーマー(個人勢)")
    ]
    
    // 動的プラットフォーム選択肢を生成（schedules.nameから収集、「レベル」を含むものは除外）
    var availablePlatforms: [String] {
        let allPlatforms = apiClient.livers.compactMap { liver in
            liver.schedules?.map { $0.name }
        }.flatMap { $0 }
        
        // 「レベル」を含むプラットフォーム名を除外
        let filteredPlatforms = allPlatforms.filter { platform in
            !platform.contains("レベル")
        }
        
        let uniquePlatforms = Array(Set(filteredPlatforms))
        
        // 優先順序を設定：YouTube, TikTok, Twitch を最初に表示
        let priorityPlatforms = ["YouTube", "TikTok", "Twitch"]
        var sortedPlatforms: [String] = []
        
        // 優先プラットフォームを最初に追加
        for priority in priorityPlatforms {
            if uniquePlatforms.contains(priority) {
                sortedPlatforms.append(priority)
            }
        }
        
        // 残りのプラットフォームをアルファベット順で追加
        let remainingPlatforms = uniquePlatforms.filter { !priorityPlatforms.contains($0) }.sorted()
        sortedPlatforms.append(contentsOf: remainingPlatforms)
        
        return sortedPlatforms
    }
    
    // 選択されたプラットフォームに対応するライバーをフィルタリング
    // schedules.name との一致でフィルタリング
    var filteredLiversByPlatform: [Liver] {
        guard let selectedPlatform = selectedPlatform else { return apiClient.livers }
        
        return apiClient.livers.filter { liver in
            liver.schedules?.contains { schedule in
                schedule.name == selectedPlatform
            } ?? false
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Header()
                
                ZStack {
                    TabButton(
                        index: 0,
                        selectedTab: $selectedTab,
                        text: "ジャンルから探す",
                        imageName: "tabicon1",
                        backgroundColor: Color(red: 96/255, green: 212/255, blue: 200/255)
                    )
                    .frame(width: UIScreen.main.bounds.width / 2) // ✅ タブの幅を調整
                    .offset(x: -UIScreen.main.bounds.width * 0.17) // ✅ 左端に寄せる
                    .zIndex(selectedTab == 0 ? 1 : 0) // ✅ 選択中のタブを前面に

                    TabButton(
                        index: 1,
                        selectedTab: $selectedTab,
                        text: "配信アプリから探す",
                        imageName: "tabicon2",
                        backgroundColor: Color.purple
                    )
                    .frame(width: UIScreen.main.bounds.width / 2) // ✅ タブの幅を調整
                    .offset(x: UIScreen.main.bounds.width * 0.17) // ✅ 右端に寄せる
                    .zIndex(selectedTab == 1 ? 1 : 0) // ✅ 選択中のタブを前面に
                }
                .offset(y: 40)
                .frame(maxWidth: .infinity) // ✅ ZStack を横幅いっぱいにする
                .padding(.top, -15)
                .background(Color(red: 96/255, green: 212/255, blue: 200/255))
                
                // コンテンツエリア
                if selectedTab == 0 {
                    // ジャンルから探す
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(genres) { genre in
                                NavigationLink(destination: GenreLiverListView(selectedGenre: genre.name)) {
                                    GenreCardView(genre: genre)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                    .background(Color.white)
                } else {
                    // 配信アプリから探す（APIデータ使用）
                    VStack(spacing: 0) {
                        PlatformSelectionView(selectedPlatform: $selectedPlatform, availablePlatforms: availablePlatforms)
                        
                        if apiClient.isLoading {
                            Spacer()
                            ProgressView("読み込み中...")
                                .scaleEffect(1.5)
                            Spacer()
                        } else if let errorMessage = apiClient.errorMessage {
                            Spacer()
                            VStack {
                                Text("エラーが発生しました")
                                    .font(.headline)
                                    .padding(.bottom, 10)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.bottom, 20)
                                Button("再試行") {
                                    Task {
                                        await apiClient.fetchLivers()
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            Spacer()
                        } else if filteredLiversByPlatform.isEmpty {
                            Spacer()
                            VStack {
                                Text("該当するライバーが見つかりませんでした")
                                    .font(.headline)
                                    .padding(.bottom, 10)
                                Text("選択されたプラットフォームのライバーはいません")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        } else {
                            List {
                                ForEach(filteredLiversByPlatform) { liver in
                                    PlatformLiverRow(liver: liver, reviewStatsStore: reviewStatsStore)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedLiver = liver
                                        }
                                        .task {
                                            await reviewStatsStore.loadReviewCount(for: liver.originalId)
                                        }
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets())
                                }
                            }
                            .listStyle(.plain)
                            .background(Color.white)
                        }
                    }
                }
            }
        }
        .onAppear {
            if apiClient.livers.isEmpty {
                Task {
                    await apiClient.fetchLivers()
                    // データ読み込み後、最初のプラットフォームを自動選択
                    if selectedPlatform == nil, let firstPlatform = availablePlatforms.first {
                        selectedPlatform = firstPlatform
                    }
                }
            }
        }
        .sheet(item: $selectedLiver) { liver in
            LiverDetailsView(liver: liver)
                .presentationDetents([.medium, .large])
                .presentationBackgroundInteraction(.enabled)
                .presentationCornerRadius(60)
        }
        .sheet(isPresented: $isShowingDetail) {
            LiverDetails() // 既存の詳細画面（後方互換性のため）
                .presentationDetents([.medium, .large])
                .presentationBackgroundInteraction(.enabled)
                .presentationCornerRadius(50)
        }
    }
}

// ジャンルカードビュー
struct GenreCardView: View {
    let genre: Genre
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 180)
                .overlay(
                    VStack(spacing: 0) {
                        Image(genre.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: genre.imageName == "zatudan" ? 80 : 100, 
                                   height: genre.imageName == "zatudan" ? 80 : 100)
                            .padding(.top, 30)
                        
                        Spacer()
                        
                        Text(genre.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 95/255, green: 211/255, blue: 198/255))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 8)
                            .padding(.bottom,20)
                    }
                )
        }
        .frame(maxWidth: .infinity)
    }
}

// プラットフォーム別ライバー行
struct PlatformLiverRow: View {
    let liver: Liver
    @ObservedObject var reviewStatsStore: ReviewStatsStore
    
    var body: some View {
        let reviewCount = reviewStatsStore.reviewCount(for: liver.originalId) ?? 0
        let displayPlatform = Liver.platformDisplayName(from: liver.platform)
        
        HStack(alignment: .top, spacing: 10) {
            AsyncImage(url: URL(string: liver.fullImageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 60)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.6)
                    )
            }
            
            VStack(alignment: .leading, spacing: 5) {
                // 上段：ライバー名、コメントアイコン、数値、フォロワー情報
                HStack(spacing: 5) {
                    Text(liver.name)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Image("commentimg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                    
                    Text("\(reviewCount)")
                        .font(.system(size: 16, weight: .bold))
                    
                    Spacer()
                    
                    Text("\(displayPlatform)フォロワー：\(liver.followerDisplayText)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                }
                
                // 下段：カテゴリと星評価
                HStack(spacing: 5) {
                    // カテゴリをテキストで表示（省略対応）
                    if let categories = liver.categories {
                        ForEach(categories.prefix(3), id: \.self) { category in
                            Text(category.count > 8 ? String(category.prefix(6)) + "..." : category)
                                .font(.system(size: 10, weight: .semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(red: 95/255, green: 211/255, blue: 198/255))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    // 星評価
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < 5 ? "star.fill" : "star")
                                .font(.system(size: 14))
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 10)
        .padding(.horizontal, 10)
        .padding(.bottom, 0)
        
        HStack {
            Spacer()
            Divider()
                .frame(width: 350, height: 2)
                .background(Color.black.opacity(0.2))
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
