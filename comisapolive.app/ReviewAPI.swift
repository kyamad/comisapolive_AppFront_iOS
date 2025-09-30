import Foundation

// MARK: - Review Data Models

struct ReviewResponse: Codable {
    let success: Bool
    let liverId: String
    let reviews: [Review]
    let total: Int
    
    private enum CodingKeys: String, CodingKey {
        case success
        case liverId = "liver_id"
        case reviews
        case total
    }
}

struct Review: Codable, Identifiable {
    let id: Int
    let rating: Int
    let comment: String
    let createdAt: Int64
    
    private enum CodingKeys: String, CodingKey {
        case id
        case rating
        case comment
        case createdAt = "created_at"
    }
    
    // 日付表示用の計算プロパティ
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: TimeInterval(createdAt / 1000))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

struct ReviewStats: Codable {
    let success: Bool
    let liverId: String
    let averageRating: Double
    let reviewCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case success
        case liverId = "liver_id" 
        case averageRating = "average_rating"
        case reviewCount = "review_count"
    }
}

struct ReviewSubmissionRequest: Codable {
    let liverId: String
    let rating: Int
    let comment: String
    
    private enum CodingKeys: String, CodingKey {
        case liverId = "liver_id"
        case rating
        case comment
    }
}

struct ReviewSubmissionResponse: Codable {
    let success: Bool
    let reviewId: Int?
    let message: String?
    let error: String?
    let remainingSeconds: Int?
    
    private enum CodingKeys: String, CodingKey {
        case success
        case reviewId = "review_id"
        case message
        case error
        case remainingSeconds
    }
}

// MARK: - Review API Client

@MainActor
class ReviewAPIClient: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var reviewStats: ReviewStats?
    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let baseURL = "https://liver-scraper-main.pwaserve8.workers.dev"
    
    // 口コミ一覧取得
    func fetchReviews(for liverId: String) async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/api/reviews/\(liverId)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Reviews HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                    isLoading = false
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let reviewResponse = try decoder.decode(ReviewResponse.self, from: data)
            
            if reviewResponse.success {
                self.reviews = reviewResponse.reviews
            } else {
                self.reviews = []
            }
            
            print("Successfully loaded \(self.reviews.count) reviews for liver \(liverId)")
            
        } catch {
            print("Reviews API Error: \(error)")
            errorMessage = "口コミの取得に失敗しました"
            self.reviews = []
        }
        
        isLoading = false
    }
    
    // 平均評価取得
    func fetchReviewStats(for liverId: String) async {
        guard let url = URL(string: "\(baseURL)/api/reviews/stats/\(liverId)") else {
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                let stats = try decoder.decode(ReviewStats.self, from: data)
                
                if stats.success {
                    self.reviewStats = stats
                    print("Successfully loaded review stats: avg=\(stats.averageRating), count=\(stats.reviewCount)")
                }
            }
            
        } catch {
            print("Review stats API Error: \(error)")
        }
    }
    
    // 口コミ投稿
    func submitReview(liverId: String, rating: Int, comment: String) async -> Bool {
        isSubmitting = true
        errorMessage = nil
        successMessage = nil
        
        guard let url = URL(string: "\(baseURL)/api/reviews") else {
            errorMessage = "Invalid URL"
            isSubmitting = false
            return false
        }
        
        let request = ReviewSubmissionRequest(liverId: liverId, rating: rating, comment: comment)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(request)
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Submit review HTTP Status Code: \(httpResponse.statusCode)")
                
                let decoder = JSONDecoder()
                let submissionResponse = try decoder.decode(ReviewSubmissionResponse.self, from: data)
                
                if submissionResponse.success {
                    successMessage = submissionResponse.message ?? "口コミを投稿しました"
                    
                    // 投稿成功時は口コミリストを再取得
                    await fetchReviews(for: liverId)
                    await fetchReviewStats(for: liverId)
                    
                    // 投稿済みライバーとして記録
                    UserDefaultsManager.shared.markLiverAsReviewed(liverId)
                    
                    isSubmitting = false
                    return true
                } else {
                    if httpResponse.statusCode == 429 {
                        // レート制限エラー
                        if let remainingSeconds = submissionResponse.remainingSeconds {
                            let minutes = remainingSeconds / 60
                            let seconds = remainingSeconds % 60
                            errorMessage = "投稿制限中です。あと\(minutes)分\(seconds)秒お待ちください。"
                        } else {
                            errorMessage = submissionResponse.error ?? "投稿制限中です。しばらくお待ちください。"
                        }
                    } else {
                        errorMessage = submissionResponse.error ?? "投稿に失敗しました"
                    }
                }
            }
            
        } catch {
            print("Submit review error: \(error)")
            errorMessage = "ネットワークエラーが発生しました"
        }
        
        isSubmitting = false
        return false
    }
    
    // エラーメッセージクリア
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}

// MARK: - UserDefaults Manager

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let reviewedLiversKey = "reviewedLivers"
    
    private init() {}
    
    func hasReviewedLiver(_ liverId: String) -> Bool {
        let reviewedLivers = UserDefaults.standard.array(forKey: reviewedLiversKey) as? [String] ?? []
        return reviewedLivers.contains(liverId)
    }
    
    func markLiverAsReviewed(_ liverId: String) {
        var reviewedLivers = UserDefaults.standard.array(forKey: reviewedLiversKey) as? [String] ?? []
        if !reviewedLivers.contains(liverId) {
            reviewedLivers.append(liverId)
            UserDefaults.standard.set(reviewedLivers, forKey: reviewedLiversKey)
        }
    }
}