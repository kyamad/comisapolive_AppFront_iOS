import SwiftUI

struct UserReviewDetails: View {
    let reviews: [Review] // ✅ 配列に変更
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                ForEach(reviews.prefix(3)) { review in // ✅ 配列なので `prefix(3)` が使える
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
                Spacer()
            }
            .padding(.top, 50)
        }
    }
}
