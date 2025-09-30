import SwiftUI

struct UserReviewDetails: View {
    let reviews: [Review]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(reviews) { review in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(review.comment)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
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
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("口コミ一覧")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
