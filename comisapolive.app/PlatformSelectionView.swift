import SwiftUI

struct PlatformSelectionView: View {
    @Binding var selectedPlatform: String?
    let availablePlatforms: [String]

    // プラットフォーム名と画像のマッピング
    private func getImageName(for platform: String) -> String {
        switch platform.lowercased() {
        case "youtube": return "youtube"
        case "tiktok": return "tiktok"  
        case "17live": return "17live"
        case "twitch": return "twitch"
        case "ツイキャス": return "twicas"
        case "ニコニコ生放送", "ニコニコ": return "niconico"
        case "pococha", "pocpcha": return "pococha"
        case "ミクチャ": return "mixch"
        case "iriam": return "iriam"
        case "bigo live", "bigo": return "bigo"
        case "hakuna": return "hakuna"
        case "reality": return "reality"
        case "stellamy": return "stellamy"
        default: return "other"
        }
    }

    var body: some View {
        VStack(spacing: 0) { // ✅ spacingを0にして余白を最小化
            // ✅ 横スクロール可能な画像リスト
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 5) { 
                    ForEach(availablePlatforms, id: \.self) { platform in
                        let isSelected = selectedPlatform == platform

                        VStack(spacing: 0) {
                            Image(getImageName(for: platform))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(5)
                                .background(isSelected ? Color(red: 235/255, green: 243/255, blue: 242/255) : Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 2)
                                .onTapGesture {
                                    withAnimation {
                                        selectedPlatform = platform
                                    }
                                }
                                .padding(.bottom, 10)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 15)
            }
            .frame(height: 70) // ✅ 高さを適切に固定
            .background(Color(red: 235/255, green: 243/255, blue: 242/255))

            if let selectedPlatform = selectedPlatform {
                HStack {
                    Image(getImageName(for: selectedPlatform))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)

                    Text("\(selectedPlatform)で配信しているライバーを探す")
                        .font(.system(size: 18, weight: .bold))
                }
                .padding(.top, 7)
                .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(red: 235/255, green: 243/255, blue: 242/255))
    }
}

#Preview {
    ContentView()
}
