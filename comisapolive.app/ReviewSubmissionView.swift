import SwiftUI

struct ReviewSubmissionView: View {
    let liverId: String
    @ObservedObject var reviewAPI: ReviewAPIClient
    @Environment(\.dismiss) private var dismiss
    
    @State private var rating: Int = 5
    @State private var comment: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let maxCommentLength = 1000
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 評価選択
                    VStack(alignment: .leading, spacing: 10) {
                        Text("評価")
                            .font(.system(size: 18, weight: .bold))
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { index in
                                Button(action: {
                                    rating = index
                                }) {
                                    Image(systemName: index <= rating ? "star.fill" : "star")
                                        .font(.system(size: 30))
                                        .foregroundColor(index <= rating ? .yellow : .gray)
                                }
                            }
                            
                            Spacer()
                            
                            Text("\(rating)点")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // コメント入力
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("コメント")
                                .font(.system(size: 18, weight: .bold))
                            
                            Spacer()
                            
                            Text("\(comment.count)/\(maxCommentLength)")
                                .font(.system(size: 14))
                                .foregroundColor(comment.count > maxCommentLength ? .red : .secondary)
                        }
                        
                        TextEditor(text: $comment)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(comment.count > maxCommentLength ? Color.red : Color.clear, lineWidth: 1)
                            )
                        
                        if comment.isEmpty {
                            Text("配信者への感想やコメントを入力してください")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.top, -8)
                        }
                        
                        if comment.count > maxCommentLength {
                            Text("コメントが長すぎます（最大\(maxCommentLength)文字）")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }
                    }
                    
                    // エラーメッセージ
                    if let errorMessage = reviewAPI.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // 成功メッセージ
                    if let successMessage = reviewAPI.successMessage {
                        Text(successMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("口コミを投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("投稿") {
                        submitReview()
                    }
                    .disabled(comment.isEmpty || comment.count > maxCommentLength || reviewAPI.isSubmitting)
                }
            }
        }
        .onAppear {
            reviewAPI.clearMessages()
        }
        .alert("投稿完了", isPresented: $showingAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func submitReview() {
        guard !comment.isEmpty && comment.count <= maxCommentLength else {
            return
        }
        
        Task {
            let success = await reviewAPI.submitReview(
                liverId: liverId,
                rating: rating,
                comment: comment
            )
            
            if success {
                alertMessage = reviewAPI.successMessage ?? "口コミを投稿しました"
                showingAlert = true
            }
        }
    }
}

#Preview {
    ReviewSubmissionView(liverId: "158", reviewAPI: ReviewAPIClient())
}