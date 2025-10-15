import SwiftUI

struct NewLiverCarousel: View {
    let livers: [Liver]
    let onLiverTap: (Liver) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(Array(livers.enumerated()), id: \.offset) { index, liver in
                    NewLiverCard(liver: liver)
                        .onTapGesture {
                            onLiverTap(liver)
                        }
                }
            }
            .padding(.horizontal, 15)
        }
        .frame(height: 210)
    }
}

struct NewLiverCard: View {
    let liver: Liver
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 10)
            
            ZStack {
                WithBackground() // 背景の点々を追加
                
                AsyncImage(url: URL(string: liver.fullImageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        .shadow(radius: 5)
                } placeholder: {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 180, height: 180)
                        
                        ProgressView()
                            .scaleEffect(1.2)
                    }
                }
            }
            
            Spacer(minLength: 10)
        }
        .frame(width: 200)
    }
}

private struct WithBackground: View {
    let dotSpacing: CGFloat = 10
    let maxRadius: CGFloat = 95
    
    private var dots: [(x: CGFloat, y: CGFloat)] {
        var points: [(CGFloat, CGFloat)] = []
        for radius in stride(from: 0, through: maxRadius, by: dotSpacing) {
            let circumference = 2 * .pi * radius
            let pointCount = max(1, Int(circumference / dotSpacing))
            for index in 0..<pointCount {
                let angle = (2 * .pi / CGFloat(pointCount)) * CGFloat(index)
                let x = radius * cos(angle)
                let y = radius * sin(angle)
                points.append((x, y))
            }
        }
        return points
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.clear)
                .frame(width: 250, height: 250)
            
            ForEach(Array(dots.enumerated()), id: \.offset) { item in
                Circle()
                    .fill(Color.white)
                    .frame(width: 5, height: 5)
                    .position(x: item.element.x + 150, y: item.element.y + 100)
            }
        }
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
            categories: ["ゲーム配信"],
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
    
    NewLiverCarousel(livers: [sampleLiver, sampleLiver, sampleLiver]) { _ in }
        .background(Color(red: 96/255, green: 212/255, blue: 200/255))
}
