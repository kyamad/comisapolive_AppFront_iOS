import Foundation

// MARK: - Data Models
struct LiverResponse: Codable {
    let timestamp: TimeInterval?
    let total: Int?
    let data: [Liver]?
    
    // 新しいAPI構造対応（timestampの型変更対応）
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        if let container = container {
            // オブジェクト形式の場合（新API構造）
            // timestampの型変更対応：String（ISO 8601）または数値型
            if let stringTimestamp = try? container.decode(String.self, forKey: .timestamp) {
                // ISO 8601文字列をタイムスタンプに変換
                timestamp = ISO8601DateFormatter().date(from: stringTimestamp)?.timeIntervalSince1970
            } else if let numericTimestamp = try? container.decode(TimeInterval.self, forKey: .timestamp) {
                // 従来の数値型
                timestamp = numericTimestamp
            } else if let int64Timestamp = try? container.decode(Int64.self, forKey: .timestamp) {
                // Int64型（後方互換性）
                timestamp = TimeInterval(int64Timestamp / 1000) // ミリ秒を秒に変換
            } else {
                timestamp = nil
            }
            
            total = try container.decodeIfPresent(Int.self, forKey: .total)
            data = try container.decodeIfPresent([Liver].self, forKey: .data)
        } else {
            // 直接配列の場合（後方互換性）
            timestamp = nil
            total = nil
            let singleContainer = try decoder.singleValueContainer()
            data = try singleContainer.decode([Liver].self)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case timestamp, total, data
    }
}

struct Liver: Codable, Identifiable {
    // 基本情報
    let id: String
    let originalId: String
    let name: String
    let platform: String
    let followers: Int
    let imageUrl: String
    let actualImageUrl: String?
    let detailUrl: String?
    let pageNumber: Int?
    let updatedAt: Int64?
    
    // 詳細情報（ネストされたオブジェクト）
    let details: LiverDetailsData?
    
    // 下位互換性のための計算プロパティ
    var collaborationStatus: String? { details?.collaborationStatus }
    var collaborationComment: String? { details?.collaborationComment }
    var collaboOK: String? { details?.collaborationComment }
    var detailName: String? { details?.detailName }
    var detailFollowers: String? { details?.detailFollowers }
    var categories: [String]? { 
        // 重複を除去してからカテゴリを返す
        guard let detailCategories = details?.categories else { return nil }
        return Array(Set(detailCategories))
    }
    var profileInfo: ProfileInfo? { details?.profileInfo }
    var profileImages: [ProfileImage]? { details?.profileImages }
    var eventInfo: [String]? { details?.eventInfo }
    var comments: [String]? { details?.comments }
    var schedules: [Schedule]? { details?.schedules }
    var mediaLinks: [MediaLink]? { nil } // 新APIには存在しないため nil
    var availableStreamingUrls: [StreamingUrl] {
        guard let streamingUrls = details?.streamingUrls else { return [] }
        return streamingUrls.filter { streamingUrl in
            guard let url = streamingUrl.url, !url.isEmpty else { return false }
            if let type = streamingUrl.type, type.contains("レベル") {
                return false
            }
            return true
        }
    }
    
    func scheduleName(for urlString: String) -> String? {
        guard let schedules = schedules else { return nil }
        guard let targetCanonical = Liver.canonicalUrlIdentifier(from: urlString) else { return nil }
        if let exactMatch = schedules.first(where: { schedule in
            guard let scheduleUrl = schedule.url else { return false }
            guard let scheduleCanonical = Liver.canonicalUrlIdentifier(from: scheduleUrl) else { return false }
            return targetCanonical == scheduleCanonical || Liver.urlIdentifiersEquivalent(targetCanonical, scheduleCanonical)
        }) {
            return exactMatch.name
        }
        if let targetHostKey = Liver.normalizedHostKey(from: urlString) {
            if let hostMatch = schedules.first(where: { schedule in
                guard let scheduleUrl = schedule.url else { return false }
                return Liver.normalizedHostKey(from: scheduleUrl) == targetHostKey
            }) {
                return hostMatch.name
            }
        }
        return nil
    }

    private static let platformKeywordMappings: [(display: String, keywords: [String])] = [
        ("YouTube", ["youtube", "ユーチューブ", "youtu.be", "youtube.com"]),
        ("TikTok", ["tiktok", "tiktok.com"]),
        ("Twitch", ["twitch", "twitch.tv"]),
        ("17LIVE", ["17live", "17 live", "イチナナ", "17.live"]),
        ("Pococha", ["pococha", "ポコチャ", "pocpcha"]),
        ("ツイキャス", ["ツイキャス", "twicas", "twitcasting"]),
        ("ニコニコ生放送", ["ニコニコ", "niconico", "nicovideo"]),
        ("ミクチャ", ["ミクチャ", "mixch", "mixchannel"]),
        ("IRIAM", ["iriam"]),
        ("BIGO LIVE", ["bigo"]),
        ("HAKUNA", ["hakuna"]),
        ("REALITY", ["reality"]),
        ("Stellamy", ["stellamy"]),
        ("SHOWROOM", ["showroom", "showroom-live"]),
        ("OPENREC", ["openrec", "openrec.tv"]),
        ("ふわっち", ["ふわっち", "whowatch"]),
        ("Mirrativ", ["mirrativ"]),
        ("LINE LIVE", ["linelive", "line live", "live.line"]),
        ("Instagram", ["instagram", "インスタ", "instagram.com"]),
        ("X (Twitter)", ["twitter", "ツイッター", "x (", "x(", "旧twitter"]),
        ("Facebook", ["facebook"]),
        ("Bilibili", ["bilibili"]),
        ("Discord", ["discord"]),
        ("FANBOX", ["fanbox"]),
        ("Fantia", ["fantia"]),
        ("BOOTH", ["booth"]),
        ("LINE", ["line.me", "lin.ee"]),
        ("Lit.link", ["lit.link"]),
        ("LinkTree", ["linktr.ee"]),
        ("OFUSE", ["ofuse.me"]),
        ("note", ["note.com"]),
        ("Patreon", ["patreon"]),
        ("Pixiv", ["pixiv"]),
        ("Skeb", ["skeb"])
    ]
    
    private static func matchPlatform(from text: String) -> String? {
        let lowercased = text.lowercased()
        for mapping in platformKeywordMappings {
            for keyword in mapping.keywords {
                let keywordLower = keyword.lowercased()
                if lowercased.contains(keywordLower) {
                    return mapping.display
                }
            }
        }
        return nil
    }
    
    private static func canonicalUrlIdentifier(from urlString: String) -> String? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let url = normalizedURL(from: trimmed) else { return trimmed.lowercased() }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return trimmed.lowercased() }
        components.scheme = nil
        components.user = nil
        components.password = nil
        components.fragment = nil
        let host = (components.host ?? "").lowercased()
        var path = components.percentEncodedPath
        if path.isEmpty { path = "/" }
        if path.count > 1, path.hasSuffix("/") {
            path.removeLast()
        }
        let query = components.percentEncodedQuery.map { "?\($0)" } ?? ""
        return host + path + query
    }
    
    private static func urlIdentifiersEquivalent(_ lhs: String, _ rhs: String) -> Bool {
        if lhs == rhs { return true }
        if lhs.hasPrefix(rhs) || rhs.hasPrefix(lhs) {
            return true
        }
        // 冗長な末尾のスラッシュ差異を許容
        let lhsTrimmed = lhs.hasSuffix("/") ? String(lhs.dropLast()) : lhs
        let rhsTrimmed = rhs.hasSuffix("/") ? String(rhs.dropLast()) : rhs
        if lhsTrimmed == rhsTrimmed { return true }
        return false
    }

    private static func normalizedURL(from urlString: String) -> URL? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }
        return URL(string: "https://" + trimmed)
    }

    static func normalizedHostKey(from urlString: String) -> String? {
        guard let url = normalizedURL(from: urlString), let host = url.host else { return nil }
        return normalizedHost(from: host)
    }

    static func normalizedHost(from host: String) -> String {
        var value = host.lowercased()
        while value.hasPrefix("www.") {
            value.removeFirst(4)
        }
        while value.hasPrefix("m.") {
            value.removeFirst(2)
        }
        return value
    }

    static func platformDisplayName(from rawText: String) -> String {
        let trimmed = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        let normalized = trimmed.replacingOccurrences(of: "　", with: " ")
        if let match = matchPlatform(from: normalized) {
            return match
        }
        if let match = matchPlatform(from: trimmed) {
            return match
        }
        return trimmed
    }
    
    static func platformDisplayName(from url: URL) -> String? {
        guard let rawHost = url.host else { return nil }
        let normalizedHostValue = normalizedHost(from: rawHost)
        let candidates = [rawHost, normalizedHostValue]
        for candidate in candidates {
            if let match = matchPlatform(from: candidate) {
                return match
            }
        }
        let path = url.path
        if let match = matchPlatform(from: normalizedHostValue + path) {
            return match
        }
        return nil
    }

    var fullImageURL: String {
        let baseURL = "https://liver-scraper-main.pwaserve8.workers.dev"
        
        // 優先順位を変更：profileImages.url → imageUrl → actualImageUrl → originalIdベース
        
        // 1. profileImages.url（detailsがある場合で、かつ信頼できるURL）
        if let details = details,
           let profileImages = details.profileImages,
           let firstImage = profileImages.first,
           let profileUrl = firstImage.url,
           !profileUrl.isEmpty {
            print("[\(name)] Using profileImages.url: \(profileUrl)")
            return profileUrl // 既に完全なURL
        }
        
        // 2. imageUrl（より信頼性が高い）
        if !imageUrl.isEmpty {
            let url = baseURL + imageUrl
            print("[\(name)] Using imageUrl: \(url)")
            return url
        }
        
        // 3. actualImageUrl（フォールバック）
        if let actualImageUrl = actualImageUrl,
           !actualImageUrl.isEmpty {
            let url = baseURL + actualImageUrl
            print("[\(name)] Using actualImageUrl: \(url)")
            return url
        }
        
        // 4. 最終フォールバック（originalIdベース）
        let fallbackUrl = "\(baseURL)/api/images/\(originalId).jpg"
        print("[\(name)] Using fallback: \(fallbackUrl)")
        return fallbackUrl
    }
    
    
    var followerDisplayText: String {
        if followers >= 10000 {
            return "\(followers / 1000)K人"
        } else if followers >= 1000 {
            let thousands = Double(followers) / 1000.0
            return String(format: "%.1fK人", thousands)
        } else {
            return "\(followers)人"
        }
    }
    
    var mainComment: String {
        return comments?.first ?? "よろしくお願いします！"
    }
    
    var channelUrl: String {
        // 優先順位：streamingUrls → detailUrl → デフォルト
        if let firstStreamingUrl = availableStreamingUrls.first,
           let url = firstStreamingUrl.url,
           !url.isEmpty {
            return url
        }
        
        // フォールバック：APIから取得したdetailUrlがある場合はそれを使用
        if let detailUrl = detailUrl, !detailUrl.isEmpty {
            return detailUrl
        }
        
        // 最終フォールバック
        return "https://www.youtube.com/channel/UCvycHCl3r3v_MYYPI_brTag"
    }
}

// 新しいAPI構造に対応した詳細情報
struct LiverDetailsData: Codable {
    let categories: [String]?
    let detailName: String?
    let detailFollowers: String?
    let profileImages: [ProfileImage]?
    let collaborationStatus: String?
    let collaborationComment: String?
    let profileInfo: ProfileInfo?
    let rawProfileTexts: [String]?
    let eventInfo: [String]?
    let comments: [String]?
    let schedules: [Schedule]?
    let streamingUrls: [StreamingUrl]?
    let genderFound: GenderInfo?
}

struct ProfileImage: Codable {
    let url: String?
    let originalUrl: String?
}

struct ProfileInfo: Codable {
    let gender: String?
    let streamingHistory: String?
    let birthday: String?
    let age: Int?
    let height: Int?
}

struct Schedule: Codable {
    let name: String
    let url: String?
    let followers: String?
}

struct StreamingUrl: Codable {
    let url: String?
    let type: String?
    let source: String?
}

struct GenderInfo: Codable {
    let gender: String?
    let confidence: Double?
}

struct MediaLink: Codable {
    let url: String?
    let text: String?
}

// MARK: - API Client
@MainActor
class LiverAPIClient: ObservableObject {
    @Published var livers: [Liver] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // コラボOKライバー用の固定配列
    @Published private var cachedColaboLivers: [Liver] = []
    
    private let baseURL = "https://liver-scraper-main.pwaserve8.workers.dev"
    
    func fetchLivers() async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/api/livers") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // レスポンスをログ出力
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                    isLoading = false
                    return
                }
            }
            
            // JSON文字列をログ出力
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(String(jsonString.prefix(500)))...")
            }
            
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(LiverResponse.self, from: data)
            
            // データを取得
            guard let liversData = decodedResponse.data else {
                errorMessage = "No data received from API"
                isLoading = false
                return
            }
            
            // 重複を除去（originalIdベースで重複チェック）
            var uniqueLivers: [Liver] = []
            var seenOriginalIds: Set<String> = []
            
            for liver in liversData {
                if !seenOriginalIds.contains(liver.originalId) {
                    uniqueLivers.append(liver)
                    seenOriginalIds.insert(liver.originalId)
                } else {
                    print("Duplicate found and removed: \(liver.name) (originalId: \(liver.originalId))")
                }
            }
            
            // 新しい順にソート（IDの数値部分でソート）
            self.livers = uniqueLivers.sorted { liver1, liver2 in
                let id1 = Int(liver1.originalId) ?? 0
                let id2 = Int(liver2.originalId) ?? 0
                return id1 > id2
            }
            
            print("Total raw data: \(liversData.count)")
            print("After deduplication: \(self.livers.count)")
            
            print("Successfully loaded \(self.livers.count) livers")
            
            // コラボOKライバーをフィルタリングしてキャッシュ（詳細情報取得済みかつcollaborationStatus="OK"のみ）
            let colaboOKLivers = self.livers.filter { liver in
                // デバッグログ
                print("[\(liver.name)] Checking for colabo OK:")
                print("  - Has details: \(liver.details != nil)")
                
                // 詳細情報が取得されているかチェック
                guard let details = liver.details else {
                    print("  - EXCLUDED: No details")
                    return false // detailsが取得できていない場合は除外
                }
                
                print("  - collaborationStatus: \(details.collaborationStatus ?? "nil")")
                
                // collaborationStatusが"OK"のライバーのみを表示
                guard let collaborationStatus = details.collaborationStatus,
                      !collaborationStatus.isEmpty else {
                    print("  - EXCLUDED: No collaborationStatus")
                    return false // collaborationStatusが取得できていない場合は除外
                }
                
                let isOK = collaborationStatus.uppercased() == "OK"
                print("  - Result: \(isOK ? "INCLUDED" : "EXCLUDED")")
                return isOK
            }
            
            // Newライバー（上位5人）のIDを取得
            let newLiverIds = Set(Array(self.livers.prefix(5)).map { $0.id })
            
            // コラボOKライバーを完全ランダムで表示（重複チェックは行わない）
            // 利用可能なコラボOKライバー全てをランダム順序で表示
            if !colaboOKLivers.isEmpty {
                self.cachedColaboLivers = Array(colaboOKLivers.shuffled())
                print("Showing all \(colaboOKLivers.count) colabo OK livers in random order")
            } else {
                self.cachedColaboLivers = []
                print("No valid colabo OK livers found")
            }
            
            print("Total livers: \(self.livers.count)")
            print("Colabo OK livers: \(colaboOKLivers.count)")
            print("Cached colabo livers: \(self.cachedColaboLivers.count)")
            print("New livers IDs: \(newLiverIds)")
            print("Colabo livers IDs: \(Set(self.cachedColaboLivers.map { $0.id }))")
            
            // 実際に表示されるコラボOKライバーの詳細をログ出力
            print("=== Final Colabo OK Livers ===")
            for (index, liver) in self.cachedColaboLivers.enumerated() {
                print("Colabo Liver \(index + 1): \(liver.name)")
                print("  - Has details: \(liver.details != nil)")
                if let details = liver.details {
                    print("  - collaborationStatus: \(details.collaborationStatus ?? "nil")")
                } else {
                    print("  - collaborationStatus: NO DETAILS")
                }
            }
            
            // 最初の数人のライバー情報をログ出力（デバッグ用）
            for (index, liver) in self.livers.prefix(3).enumerated() {
                print("Liver \(index + 1): \(liver.name)")
                print("  - ID: \(liver.id)")
                print("  - Original ID: \(liver.originalId)")
                print("  - Image URL: \(liver.imageUrl)")
                print("  - Full Image URL: \(liver.fullImageURL)")
                print("  - Platform: \(liver.platform)")
                print("  - Followers: \(liver.followers)")
            }
            
        } catch {
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    errorMessage = "Missing key: \(key.stringValue) at \(context.codingPath)"
                case .typeMismatch(let type, let context):
                    errorMessage = "Type mismatch for \(type) at \(context.codingPath)"
                case .valueNotFound(let type, let context):
                    errorMessage = "Value not found for \(type) at \(context.codingPath)"
                case .dataCorrupted(let context):
                    errorMessage = "Data corrupted at \(context.codingPath)"
                @unknown default:
                    errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            } else {
                errorMessage = "Network error: \(error.localizedDescription)"
            }
            print("API Error: \(error)")
        }
        
        isLoading = false
    }
    
    // 新着ライバー（上位5人）を取得
    var newLivers: [Liver] {
        let selected = Array(livers.prefix(5))
        print("NewLivers: \(selected.map { "\($0.name)(\($0.id))" })")
        return selected
    }
    
    // コラボOKライバー（キャッシュされた配列を返す）
    var colaboLivers: [Liver] {
        print("ColaboLivers: \(cachedColaboLivers.map { "\($0.name)(\($0.id))" })")
        
        // 再度重複チェック（安全のため）
        let newLiverIds = Set(Array(livers.prefix(5)).map { $0.id })
        let filteredColabo = cachedColaboLivers.filter { liver in
            !newLiverIds.contains(liver.id)
        }
        
        if filteredColabo.count >= 3 {
            print("Filtered ColaboLivers: \(filteredColabo.map { "\($0.name)(\($0.id))" })")
            return Array(filteredColabo.prefix(5))
        } else {
            print("Using cached ColaboLivers (insufficient filtered)")
            return cachedColaboLivers
        }
    }
}
