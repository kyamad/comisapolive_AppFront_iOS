import SwiftUI

struct GenreLiverListView: View {
    let selectedGenre: String
    @StateObject private var apiClient = LiverAPIClient()
    @State private var selectedLiver: Liver? = nil
    
    // 選択されたジャンルに対応するライバーをフィルタリング
    var filteredLivers: [Liver] {
        return apiClient.livers.filter { liver in
            guard let categories = liver.categories else { return false }
            return categories.contains(selectedGenre)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack {
                Text("\(selectedGenre) のライバー")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Spacer()
            }
            
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
            } else if filteredLivers.isEmpty {
                Spacer()
                VStack {
                    Text("該当するライバーが見つかりませんでした")
                        .font(.headline)
                        .padding(.bottom, 10)
                    Text("\"\(selectedGenre)\" に対応するライバーはいません")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                // ライバー一覧
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredLivers) { liver in
                            GenreLiverCard(liver: liver)
                                .onTapGesture {
                                    selectedLiver = liver
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if apiClient.livers.isEmpty {
                Task {
                    await apiClient.fetchLivers()
                }
            }
        }
        .sheet(item: $selectedLiver) { liver in
            LiverDetailsView(liver: liver)
                .presentationDetents([.medium, .large])
                .presentationBackgroundInteraction(.enabled)
                .presentationCornerRadius(60)
        }
    }
}

// ジャンル別ライバーカード
struct GenreLiverCard: View {
    let liver: Liver
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // 左側の画像
            AsyncImage(url: URL(string: liver.fullImageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            }
            
            // 右側の情報
            VStack(alignment: .leading, spacing: 5) {
                // ライバー名
                Text(liver.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                // フォロワー情報
                HStack {
                    Text(liver.platform)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(liver.followerDisplayText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                // カテゴリ情報
                if let categories = liver.categories, !categories.isEmpty {
                    Text(categories.joined(separator: " • "))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 95/255, green: 211/255, blue: 198/255))
                        .lineLimit(3)
                        .padding(.top, 2)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        GenreLiverListView(selectedGenre: "ゲーム配信")
    }
}