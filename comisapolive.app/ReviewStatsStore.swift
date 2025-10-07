import Foundation

@MainActor
final class ReviewStatsStore: ObservableObject {
    @Published private(set) var reviewCounts: [String: Int] = [:]
    private var loadingIds: Set<String> = []
    private let baseURL = "https://liver-scraper-main.pwaserve8.workers.dev"
    
    func reviewCount(for liverId: String) -> Int? {
        reviewCounts[liverId]
    }
    
    func loadReviewCount(for liverId: String) async {
        if reviewCounts[liverId] != nil { return }
        guard !loadingIds.contains(liverId) else { return }
        loadingIds.insert(liverId)
        defer { loadingIds.remove(liverId) }
        
        guard let url = URL(string: "\(baseURL)/api/reviews/stats/\(liverId)") else {
            reviewCounts[liverId] = 0
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                reviewCounts[liverId] = 0
                return
            }
            
            let decoder = JSONDecoder()
            let stats = try decoder.decode(ReviewStats.self, from: data)
            reviewCounts[liverId] = stats.success ? stats.reviewCount : 0
        } catch {
            reviewCounts[liverId] = 0
        }
    }
}

