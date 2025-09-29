import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedLiver: Liver? = nil
    @StateObject private var apiClient = LiverAPIClient()
    @State private var searchHistory: [String] = []
    @State private var isTextFieldFocused = false
    @FocusState private var isSearchFieldFocused: Bool
    
    // 検索条件に一致するライバーをフィルタリング
    var filteredLivers: [Liver] {
        if searchText.isEmpty {
            return []
        }
        
        let lowercasedSearch = searchText.lowercased()
        
        return apiClient.livers.filter { liver in
            // name での検索
            if liver.name.lowercased().contains(lowercasedSearch) {
                return true
            }
            
            // categories での検索
            if let categories = liver.categories {
                for category in categories {
                    if category.lowercased().contains(lowercasedSearch) {
                        return true
                    }
                }
            }
            
            // profileInfo.gender での検索
            if let gender = liver.profileInfo?.gender,
               gender.lowercased().contains(lowercasedSearch) {
                return true
            }
            
            // comments での検索
            if let comments = liver.comments {
                for comment in comments {
                    if comment.lowercased().contains(lowercasedSearch) {
                        return true
                    }
                }
            }
            
            // schedules での検索
            if let schedules = liver.schedules {
                for schedule in schedules {
                    if schedule.name.lowercased().contains(lowercasedSearch) {
                        return true
                    }
                }
            }
            
            return false
        }
    }
    
    // 検索履歴の管理
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
    }
    
    private func saveSearchHistory() {
        UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
    }
    
    private func addToSearchHistory(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        // 既存の履歴から同じクエリを削除
        searchHistory.removeAll { $0 == trimmedQuery }
        
        // 新しいクエリを先頭に追加
        searchHistory.insert(trimmedQuery, at: 0)
        
        // 履歴を最大10件まで制限
        if searchHistory.count > 10 {
            searchHistory = Array(searchHistory.prefix(10))
        }
        
        saveSearchHistory()
    }
    
    private func clearSearchHistory() {
        searchHistory.removeAll()
        saveSearchHistory()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 検索バー
            VStack(spacing: 15) {
                Text("ライバー検索")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.top, 20)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    
                    TextField("ライバー名、カテゴリ、性別などで検索", text: $searchText)
                        .font(.system(size: 16))
                        .padding(.vertical, 12)
                        .padding(.trailing, 10)
                        .submitLabel(.done)
                        .focused($isSearchFieldFocused)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.default)
                        .onSubmit {
                            if !searchText.isEmpty {
                                addToSearchHistory(searchText)
                                isSearchFieldFocused = false
                            }
                        }
                        .onTapGesture {
                            isSearchFieldFocused = true
                        }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
            .background(Color.white)
            
            // 検索履歴表示
            if isSearchFieldFocused && searchText.isEmpty && !searchHistory.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("検索履歴")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Button("クリア") {
                            clearSearchHistory()
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    ForEach(searchHistory, id: \.self) { historyItem in
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            
                            Text(historyItem)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Button(action: {
                                searchHistory.removeAll { $0 == historyItem }
                                saveSearchHistory()
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .onTapGesture {
                            searchText = historyItem
                            isSearchFieldFocused = false
                        }
                        
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
                .background(Color.white)
                .transition(.opacity)
            }
            
            // 検索結果
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
            } else if searchText.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.bottom, 20)
                    
                    Text("検索したいキーワードを入力してください")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    
                    Text("ライバー名、カテゴリ、性別などで検索できます")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.7))
                }
                Spacer()
            } else if filteredLivers.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "exclamationmark.magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.bottom, 20)
                    
                    Text("検索結果が見つかりませんでした")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    
                    Text("\"\(searchText)\" に一致するライバーはいません")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.7))
                }
                Spacer()
            } else {
                // 検索結果一覧
                ScrollView {
                    LazyVStack(spacing: 15) {
                        Text("検索結果: \(filteredLivers.count)件")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        ForEach(filteredLivers) { liver in
                            SearchResultCard(liver: liver)
                                .onTapGesture {
                                    selectedLiver = liver
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // 検索履歴表示エリア以外をタップした時のみフォーカスを外す
            if !isSearchFieldFocused || (!searchText.isEmpty || searchHistory.isEmpty) {
                isSearchFieldFocused = false
            }
        }
        .onAppear {
            loadSearchHistory()
            if apiClient.livers.isEmpty {
                Task {
                    await apiClient.fetchLivers()
                }
            }
        }
        .onChange(of: searchText) { oldValue, newValue in
            // 検索テキストが変更されても、フォーカス状態は変更しない
            // ユーザーが入力中の場合はフォーカスを維持
        }
        .onAppear {
            // テスト用の履歴データを追加
            if searchHistory.isEmpty {
                searchHistory = ["テストライバー", "ゲーム配信", "歌配信"]
                saveSearchHistory()
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

// 検索結果カード
struct SearchResultCard: View {
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
            VStack(alignment: .leading, spacing: 8) {
                // ライバー名
                Text(liver.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                // プラットフォームとフォロワー
                HStack {
                    Text(liver.platform)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 95/255, green: 211/255, blue: 198/255))
                        .cornerRadius(6)
                    
                    Text(liver.followerDisplayText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                // カテゴリ情報
                if let categories = liver.categories, !categories.isEmpty {
                    Text(categories.joined(separator: " • "))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                // 性別情報
                if let gender = liver.profileInfo?.gender {
                    Text("性別: \(gender)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray.opacity(0.8))
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 15)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    SearchView()
}
