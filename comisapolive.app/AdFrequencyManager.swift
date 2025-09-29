import Foundation

class AdFrequencyManager: ObservableObject {
    @Published private var viewCount: Int = 0
    private let showFrequency: Int = Int.random(in: 3...5) // 3〜5回に1回
    
    func shouldShowAd() -> Bool {
        viewCount += 1
        let shouldShow = viewCount % showFrequency == 0
        return shouldShow
    }
    
    func resetCounter() {
        viewCount = 0
    }
}