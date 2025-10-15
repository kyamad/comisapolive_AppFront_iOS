import SwiftUI

// カテゴリタグ用のカスタムシェイプ（左上90°、他は角丸）
struct CategoryTagShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cornerRadius: CGFloat = 13
        
        var path = Path()
        
        // 左上から開始（90度角）
        path.move(to: CGPoint(x: 0, y: 0))
        
        // 上辺（右上は角丸）
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: cornerRadius), 
                         control: CGPoint(x: rect.width, y: 0))
        
        // 右辺（右下は角丸）
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.width - cornerRadius, y: rect.height), 
                         control: CGPoint(x: rect.width, y: rect.height))
        
        // 下辺（左下は角丸）
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.height - cornerRadius), 
                         control: CGPoint(x: 0, y: rect.height))
        
        // 左辺（左上は90度角）
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        return path
    }
}

// Color拡張（16進数カラー対応）
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ColaboLiverCarousel: View {
    let livers: [Liver]
    let onLiverTap: (Liver) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(Array(livers.enumerated()), id: \.offset) { index, liver in
                    ColaboLiverCard(liver: liver)
                        .onTapGesture {
                            onLiverTap(liver)
                        }
                }
            }
            .padding(.horizontal, 15)
        }
        .frame(height: 400)
    }
}

struct ColaboLiverCard: View {
    let liver: Liver
    
    var body: some View {
        VStack(spacing: 8) {
            // ライバー画像
            AsyncImage(url: URL(string: liver.fullImageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 270)
                    .clipShape(CustomRoundedCorners(radius: 30, corners: [.topLeft, .bottomRight]))
                    .overlay(
                        CustomRoundedCorners(radius: 30, corners: [.topLeft, .bottomRight])
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .shadow(radius: 1)
            } placeholder: {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 270)
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.2)
                    )
            }
            
            // ライバー名
            HStack {
                ZStack {
                    Text(liver.name)
                        .font(.system(size: 15, weight: .bold))
                        .padding(8)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .background(
                            Color(red: 96/255, green: 212/255, blue: 200/255)
                                .offset(x: 4, y: 4)
                                .blur(radius: 3)
                        )
                }
                Spacer()
            }
            
            // フォロワー数表示
            HStack {
                VStack(alignment: .leading) {
                    Text("\(liver.platform)フォロワー数")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Text(liver.followerDisplayText)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                
                Spacer()
            }
            .frame(width: 285)
            .background(Color.black)
            
            // カテゴリをテキストで表示
            if let categories = liver.categories, !categories.isEmpty {
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories.prefix(3), id: \.self) { category in
                                Text(category)
                                    .font(.system(size: 12, weight: .semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 5)
                                    .background(Color(red: 203/255, green: 238/255, blue: 234/255))
                                    .foregroundColor(.black)
                                    .clipShape(CategoryTagShape())
                            }
                        }
                        .padding(.horizontal, 0)
                    }
                    Spacer()
                }
                .frame(width: 270)
            }
        }
        .frame(width: 290)
    }
}

private struct CustomRoundedCorners: Shape {
    let radius: CGFloat
    let corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    let sampleLiver = Liver(
        id: "sample",
        originalId: "1",
        name: "サンプルライバー",
        platform: "YouTube",
        followers: 1234,
        imageUrl: "/api/images/sample.jpg",
        actualImageUrl: String?.none,
        detailUrl: String?.none,
        pageNumber: 1,
        updatedAt: 1753884057967,
        details: LiverDetailsData(
            categories: ["ゲーム配信", "雑談", "歌枠"],
            detailName: "サンプルライバー",
            detailFollowers: "1234",
            profileImages: nil,
            collaborationStatus: "OK",
            collaborationComment: "コラボ配信OK",
            profileInfo: nil,
            rawProfileTexts: nil,
            eventInfo: nil,
            comments: ["よろしくお願いします！"],
            schedules: nil,
            streamingUrls: nil,
            genderFound: nil
        )
    )
    
    ColaboLiverCarousel(livers: [sampleLiver, sampleLiver]) { _ in }
        .background(Color(red: 96/255, green: 212/255, blue: 200/255).opacity(0.1))
}
