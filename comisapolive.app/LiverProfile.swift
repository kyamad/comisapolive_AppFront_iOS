import SwiftUI

struct LiverProfile: View {
    let imageName: String
    let LiverName: String
    let Comment: String
    let Follower: String
    let CategoryF: String
    let CategoryS: String
    let CategoryT: String
    let Rating: Int
    
    var body: some View {
        
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            VStack(spacing: 0){
                HStack(spacing: 5) { // テキストとアイコンを横並びにする
                    Text(LiverName)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .offset(y: 12)
                    
                    Image("commentimg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                        .offset(x: -7)
                        .padding(.top, 1)
                        .offset(y: 12)
                    
                    Text(Comment)
                        .font(.system(size: 16, weight: .bold))
                        .truncationMode(.tail)
                        .offset(x: -19)
                        .padding(.bottom, 1)
                        .offset(y: 12)
                    
                    Text("YouTubeフォロワー：\(Follower)人")
                        .font(.system(size: 12, weight: .bold))
                        .truncationMode(.tail)
                        .offset(x: -17)
                        .padding(.top, 1)
                        .offset(y: 11)
                }
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 5) {
                    Image(CategoryF)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45)
                        .offset(y: 6)
                    
                    Image(CategoryS)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 25)
                        .offset(y: 6)
                    
                    Image(CategoryT)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 27)
                        .offset(y: 6)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { index in
                            
                            Image(systemName: index < Rating ? "star.fill" : "star")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.yellow)
                                .padding(.top, 9)
                                .offset(x: 6)
                        }
                    }
                    .padding(.trailing, 10) // 右端の余白調整
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: 15)
            }
        }
        .padding(.top, 10)
        HStack {
            Spacer()
            Divider()
                .frame(width: 350, height: 2)
                .background(Color.black.opacity(0.2))
                .padding(.top, 10)
            Spacer()
        }
    }
}

struct NewLivers: View {
    let imageName: String
    var borderColor: Color = .black
    var borderWidth: CGFloat = 2

    var body: some View {
        ZStack {
            WithBackground() // ✅ 背景の点々を追加
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipShape(Circle()) // 丸く切り抜く
                .overlay(Circle().stroke(borderColor, lineWidth: borderWidth))
                .shadow(radius: 5)
        }
    }
}


struct WithBackground: View {
    let dotSpacing: CGFloat = 10 // ✅ 点同士の間隔
    let maxRadius: CGFloat = 95 // ✅ 円の最大半径

    var dots: [(x: CGFloat, y: CGFloat)] {
        var points: [(CGFloat, CGFloat)] = []
        
        for r in stride(from: 0, through: maxRadius, by: dotSpacing) { // ✅ 円の半径ごとに
            let circumference = 2 * .pi * r // ✅ その半径の円周長
            let pointCount = max(1, Int(circumference / dotSpacing)) // ✅ 円周上の点の数
            
            for i in 0..<pointCount {
                let angle = (2 * .pi / CGFloat(pointCount)) * CGFloat(i) // ✅ 均等な角度で配置
                let x = r * cos(angle)
                let y = r * sin(angle)
                points.append((x, y))
            }
        }
        return points
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.clear)
                .frame(width: 250, height: 250) // ✅ 画像サイズに合わせる
            
            ForEach(dots.indices, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 5, height: 5) // ✅ 点のサイズ
                    .position(x: dots[index].x + 150, y: dots[index].y + 100)
            }
        }
    }
}

struct ScrollableImageItem: View {
    var body: some View {
        ZStack {
            WithBackground()
            NewLivers(imageName: "liver")
        }
    }
}

struct ColaboLivers: View {
    let imageName: String
    var borderColor: Color = .black
    var borderWidth: CGFloat = 2

    var body: some View {
        VStack{
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 270)
                    .clipShape(CustomRoundedCorners(radius: 30, corners: [.topLeft, .bottomRight])) // ✅ 画像の角を丸くする
                    .overlay(
                        CustomRoundedCorners(radius: 30, corners: [.topLeft, .bottomRight])
                            .stroke(borderColor, lineWidth: borderWidth) // ✅ 枠線も同じ形に
                    )
                    .shadow(radius: 1)
            }
            HStack{
                ZStack {
                    // ✅ 右下に影となる要素を配置
                    Text("姫咲 光妃")
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
            .padding(.top, 5)
            
            HStack{
                HStack(){
                    VStack(alignment: .leading){
                        Text("Youtubeフォロワー数")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Text("200")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
                .frame(width: 270)
                .background(Color.black)
                
                Spacer()
            }
            .padding(.top, 8)
            
            HStack{
                HStack{
                    Image("livecategorytalk")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40)
                    
                    Image("livecategorysong")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40)
                        .padding(.horizontal, 10)
                    
                    Image("livecategorygame")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40)
                        .padding(.horizontal, 10)
                }
                Spacer()
            }
        }
    }
}

// ✅ カスタムシェイプ（左上・右下の角のみ丸くする）
struct CustomRoundedCorners: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct ScrollableColaboLiverItem: View {
    var body: some View {
        ZStack {
            ColaboLivers(imageName: "liver")
        }
    }
}


#Preview {
    HomeView()
}
