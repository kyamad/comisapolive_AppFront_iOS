import SwiftUI

struct Review: Identifiable {
    let id = UUID()
    let Comment: String
    let rating: Int
}

let reviews = [
    Review(Comment: "口コミ口コミ口コミ", rating: 5),
    Review(Comment: "口コミ口コミ", rating: 4),
    Review(Comment: "口コミ", rating: 3),
]

struct ReviewsView: View {
    var body: some View {
        // ✅ NavigationStack を追加
        NavigationStack {
            VStack(spacing: 10) {
                ForEach(reviews.prefix(3)) { review in
                    NavigationLink(destination: UserReviewDetails(reviews: reviews)) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(review.Comment)
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

                NavigationLink(destination: UserReviewDetails(reviews: reviews)) {
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
}

#Preview {
    NavigationStack {
        LiverDetails()
    }
}
