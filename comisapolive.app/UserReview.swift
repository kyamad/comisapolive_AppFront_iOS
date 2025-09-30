import SwiftUI

struct ReviewsView: View {
    let liverId: String
    @StateObject private var reviewAPI = ReviewAPIClient()
    
    var body: some View {
        VStack(spacing: 10) {
            if reviewAPI.isLoading {
                ProgressView("口コミを読み込み中...")
                    .frame(height: 100)
            } else if reviewAPI.reviews.isEmpty {
                // 口コミがない場合の表示
                VStack(spacing: 10) {
                    Text("口コミなし")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                        .padding(.horizontal, 10)
                }
            } else {
                // 口コミ表示（最大3件）
                ForEach(reviewAPI.reviews.prefix(3)) { review in
                    NavigationLink(destination: UserReviewDetails(reviews: reviewAPI.reviews)) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(review.comment)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.bottom, 5)

                            HStack(spacing: 5) {
                                ForEach(0..<5, id: \.self) { index in
                                    Image(systemName: index < review.rating ? "star.fill" : "star")
                                        .foregroundColor(index < review.rating ? .yellow : .gray)
                                        .font(.system(size: 16))
                                }
                                
                                Spacer()
                                
                                Text(review.formattedDate)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                        .padding(.horizontal, 10)
                    }
                }

                // 口コミが3件以上ある場合のみ「もっと見る」ボタンを表示
                if reviewAPI.reviews.count > 3 {
                    NavigationLink(destination: UserReviewDetails(reviews: reviewAPI.reviews)) {
                        Text("もっと見る")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.blue)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                            .padding(.horizontal, 15)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .onAppear {
            Task {
                await reviewAPI.fetchReviews(for: liverId)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LiverDetails()
    }
}
