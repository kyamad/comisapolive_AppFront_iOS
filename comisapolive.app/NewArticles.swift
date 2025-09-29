import SwiftUI
import SafariServices

struct NewArticles: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    let articles = [
        ("Article1", "ライブ配信に人が来ない原因と対処方法｜リスナーが集まる人気配信者になるにはどうしたらいい？", "https://www.comisapolive.com/column/detail/41/"),
        ("Article2", "ビゴライブでの配信中の禁止事項｜これはバンの対象？バンされたらどうなるの？", "https://www.comisapolive.com/column/detail/40/"),
        ("Article3", "ライブ配信に向いている人の特徴｜あなたは何個当てはまる？ライブ配信で結果を出すにはどうしたらいい？", "https://www.comisapolive.com/column/detail/39/"),
        ("Article4", "ライブ配信で注意したい3つの騒音｜今すぐ手軽にできる防音対策とは", "https://www.comisapolive.com/column/detail/38/"),
        ("Article5", "TikTokで稼ぐなら「おすすめ」に乗ることが重要！おすすめに乗る条件とコツについてくわしく解説します", "https://www.comisapolive.com/column/detail/37/"),
        ("Article6", "ライバーとして稼ぐなら「TikTok Live」がおすれめ！TikTokでの収益の種類とやり方を伝授します", "https://www.comisapolive.com/column/detail/36/"),
        ("Article7", "ライブ配信をやめたいと思うのはどんな時？配信がつらくなった時の対処方法", "https://www.comisapolive.com/column/detail/35/"),
        ("Article8", "ライブ配信で病む人の特徴｜元気に配信を楽しむために意識しておきたいポイント", "https://www.comisapolive.com/column/detail/34/")
    ]
    
    @State private var selectedURL: URL?
    @State private var showingSafari = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack{
                    HStack{
                        Text("新着記事")
                            .font(.system(size: 30, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.top, 30)
                        Spacer()
                    }
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(articles, id: \.0) { article in
                            Button(action: {
                                selectedURL = URL(string: article.2)
                                showingSafari = true
                            }) {
                                VStack {
                                    let imageSize = CGSize(width: UIScreen.main.bounds.width / 2 - 20, height: 120)
                                    
                                    Image(article.0)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: imageSize.width, height: imageSize.height)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    Text(article.1)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.black)
                                        .frame(width: imageSize.width,height: 45)
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                        .padding(.vertical, 5)
                                        .background(Color.white)
                                }
                                .background(Color.white)
                                .shadow(radius: 2)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.bottom,20)
            }
            .sheet(isPresented: $showingSafari) {
                if let selectedURL = selectedURL {
                    SafariView(url: selectedURL)
                }
            }
        }
    }
}


#Preview {
    HomeView()
}
