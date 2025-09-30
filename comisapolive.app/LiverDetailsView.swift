import SwiftUI

struct LiverDetailsView: View {
    let liver: Liver
    @StateObject private var reviewAPI = ReviewAPIClient()
    @State private var showingReviewSubmission = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    AsyncImage(url: URL(string: liver.fullImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.2)
                            )
                    }
                    .padding(.top, 20)
                    
                    Text(liver.name)
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 15)
                    
                    HStack {
                        Text("活動場所")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Text(liver.platform)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    
                    HStack {
                        Text("チャンネル名")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Text(liver.name)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    HStack {
                        Text("登録者数")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Text(liver.followerDisplayText)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    HStack {
                        Text("口コミ評価")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        
                        if let stats = reviewAPI.reviewStats {
                            HStack(spacing: 5) {
                                ForEach(0..<5, id: \.self) { index in
                                    Image(systemName: index < Int(stats.averageRating.rounded()) ? "star.fill" : "star")
                                        .foregroundColor(index < Int(stats.averageRating.rounded()) ? .yellow : .gray)
                                        .font(.system(size: 16))
                                }
                                
                                Text(String(format: "%.1f", stats.averageRating))
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                
                                Text("(\(stats.reviewCount)件)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            HStack(spacing: 5) {
                                ForEach(0..<5, id: \.self) { index in
                                    Image(systemName: "star")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                }
                                Text("評価なし")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // チャンネルリンクボタン（現在は固定URL、将来的にAPI改善予定）
                    Button(action: {
                        if let url = URL(string: liver.channelUrl) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("チャンネルを見に行く")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 25)
                    
                    Text("概       要")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 35)
                        .padding(.bottom, -5)
                    
                    Text(liver.mainComment)
                        .padding(.horizontal, 15)
                        .padding(.top, 30)
                        .padding(.bottom, 30)
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0, green: 0.5, blue: 1).opacity(0.1))
                        .padding(.horizontal, 20)
                    
                    // 口コミ投稿ボタン
                    if !UserDefaultsManager.shared.hasReviewedLiver(liver.originalId) {
                        Button(action: {
                            showingReviewSubmission = true
                        }) {
                            Text("口コミを投稿する")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 30)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    } else {
                        Text("投稿済み")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                    }
                    
                    ReviewsView(liverId: liver.originalId)
                        .padding(.vertical, 10)
                    
                    // 再度チャンネルリンクボタン
                    Button(action: {
                        if let url = URL(string: liver.channelUrl) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("チャンネルを見に行く")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 50)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            Task {
                await reviewAPI.fetchReviewStats(for: liver.originalId)
            }
        }
        .sheet(isPresented: $showingReviewSubmission) {
            ReviewSubmissionView(liverId: liver.originalId, reviewAPI: reviewAPI)
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
        detailUrl: "https://www.youtube.com/channel/UCvycHCl3r3v_MYYPI_brTag",
        pageNumber: 1,
        updatedAt: 1753884057967,
        details: LiverDetailsData(
            categories: ["ゲーム配信", "雑談"],
            detailName: "サンプルライバー",
            detailFollowers: "1234",
            profileImages: nil,
            collaborationStatus: "OK",
            collaborationComment: "コラボ配信OK",
            profileInfo: ProfileInfo(gender: "女性", streamingHistory: nil, birthday: nil, age: nil, height: nil),
            rawProfileTexts: nil,
            eventInfo: nil,
            comments: ["初めまして！ゲーム配信と雑談をメインに活動しています。よろしくお願いします！"],
            schedules: [
                Schedule(name: "YouTube", url: nil, followers: "1234"),
                Schedule(name: "Twitch", url: nil, followers: "567")
            ],
            streamingUrls: nil,
            genderFound: nil
        )
    )
    
    LiverDetailsView(liver: sampleLiver)
}
