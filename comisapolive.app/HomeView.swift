import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Int = 0
    @State private var selectedPlatform: String? = "youtube"
    @State private var scrollPositionNewLiver: Int = 0 // ✅ Newライバー用
    @State private var scrollPositionColaboLiver: Int = 0 // ✅ コラボ配信OKライバー用
    @State private var selectedLiver: Liver? = nil
    @StateObject private var apiClient = LiverAPIClient()

    private let totalItems = 5 // ✅ 画像の総数

    var body: some View {
        VStack(spacing: 0) {
                Header()
                
                ScrollView {
                    VStack{
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 2)
                            .padding(.bottom, 5)
                            .offset(y: -2)
                        
                        AdMobBannerView(adUnitID: "ca-app-pub-5103020251808633/9942411882")
                            .padding()
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 2)
                            .padding(.top, 5)
                    }
                    .padding(.bottom, -7)

                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Image("NewLiver")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                    .padding(.bottom, -13)

                                Text("Newライバー")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 40)
                        .padding(.bottom, 15)

                        // ✅ 横スクロール画像リスト（APIデータ使用）
                        if apiClient.isLoading {
                            ProgressView("読み込み中...")
                                .frame(height: 200)
                        } else if let errorMessage = apiClient.errorMessage {
                            VStack {
                                Text("エラー:")
                                    .font(.headline)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Button("再試行") {
                                    Task {
                                        await apiClient.fetchLivers()
                                    }
                                }
                                .padding(.top, 10)
                            }
                            .frame(height: 200)
                        } else if apiClient.newLivers.isEmpty {
                            VStack {
                                Text("データを取得できませんでした")
                                Text("ライバー数: \(apiClient.livers.count)")
                                    .font(.caption)
                                Button("再試行") {
                                    Task {
                                        await apiClient.fetchLivers()
                                    }
                                }
                                .padding(.top, 10)
                            }
                            .frame(height: 200)
                        } else {
                            NewLiverCarousel(
                                livers: apiClient.newLivers,
                                onLiverTap: { liver in
                                    selectedLiver = liver
                                }
                            )
                            .padding(.bottom, 20)
                        }
                    }
                    .background(Color(red: 96/255, green: 212/255, blue: 200/255))
                    
                    NewArticles()
                    
                    VStack{
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 2)
                            .padding(.bottom, 5)
                            .offset(y: -2)
                        
                        AdMobBannerView(adUnitID: "ca-app-pub-5103020251808633/9942411882")
                            .padding()
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 2)
                            .padding(.top, 5)
                    }
                    .padding(.bottom, -7)
                    
                    VStack{
                        
                        HStack{
                            Text("コラボ配信OKライバー")
                                .font(.system(size: 25, weight: .bold))
                                .padding(.horizontal, 15)
                                .padding(.top, 25)
                            
                            Spacer()
                        }
                        
                        // ✅ コラボOKライバー（APIデータ使用）
                        if apiClient.isLoading {
                            ProgressView("読み込み中...")
                                .frame(height: 400)
                        } else if let errorMessage = apiClient.errorMessage {
                            VStack {
                                Text("エラー:")
                                    .font(.headline)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Button("再試行") {
                                    Task {
                                        await apiClient.fetchLivers()
                                    }
                                }
                                .padding(.top, 10)
                            }
                            .frame(height: 400)
                        } else if apiClient.colaboLivers.isEmpty {
                            VStack {
                                Text("データを取得できませんでした")
                                Text("ライバー数: \(apiClient.livers.count)")
                                    .font(.caption)
                                Button("再試行") {
                                    Task {
                                        await apiClient.fetchLivers()
                                    }
                                }
                                .padding(.top, 10)
                            }
                            .frame(height: 400)
                        } else {
                            ColaboLiverCarousel(
                                livers: apiClient.colaboLivers,
                                onLiverTap: { liver in
                                    selectedLiver = liver
                                }
                            )
                        }
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 2)
                            .padding(.top, 100)
                            .padding(.bottom, 10)
                    }
                    .background(Color(red: 96/255, green: 212/255, blue: 200/255).opacity(0.1))
                }
            }
            .onAppear {
                Task {
                    await apiClient.fetchLivers()
                }
            }
            .refreshable {
                Task {
                    await apiClient.fetchLivers()
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

#Preview {
    HomeView()
}
