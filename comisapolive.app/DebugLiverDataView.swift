import SwiftUI

struct DebugLiverDataView: View {
    @StateObject private var apiClient = LiverAPIClient()
    @State private var selectedLiver: Liver?
    
    var body: some View {
        NavigationView {
            VStack {
                if apiClient.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = apiClient.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(apiClient.livers) { liver in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(liver.name)
                                .font(.headline)
                            Text("ID: \(liver.id)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Platform: \(liver.platform)")
                                .font(.caption)
                        }
                        .onTapGesture {
                            selectedLiver = liver
                        }
                    }
                }
                
                if let selectedLiver = selectedLiver {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("選択されたライバー: \(selectedLiver.name)")
                                .font(.title2)
                                .bold()
                                .padding(.bottom)
                            
                            Group {
                                DetailRow(label: "ID", value: selectedLiver.id)
                                DetailRow(label: "Original ID", value: selectedLiver.originalId)
                                DetailRow(label: "Name", value: selectedLiver.name)
                                DetailRow(label: "Platform", value: selectedLiver.platform)
                                DetailRow(label: "Followers", value: "\(selectedLiver.followers)")
                                DetailRow(label: "Image URL", value: selectedLiver.imageUrl)
                                DetailRow(label: "Detail URL", value: selectedLiver.detailUrl ?? "N/A")
                                DetailRow(label: "Main Comment", value: selectedLiver.mainComment)
                                DetailRow(label: "Channel URL", value: selectedLiver.channelUrl)
                            }
                            
                            if let details = selectedLiver.details {
                                Text("詳細情報:")
                                    .font(.headline)
                                    .padding(.top)
                                
                                if let categories = details.categories {
                                    DetailRow(label: "Categories", value: categories.joined(separator: ", "))
                                }
                                
                                DetailRow(label: "Detail Name", value: details.detailName ?? "N/A")
                                DetailRow(label: "Detail Followers", value: details.detailFollowers ?? "N/A")
                                DetailRow(label: "Collaboration Status", value: details.collaborationStatus ?? "N/A")
                                DetailRow(label: "Collaboration Comment", value: details.collaborationComment ?? "N/A")
                                
                                if let comments = details.comments {
                                    DetailRow(label: "Comments", value: comments.joined(separator: "\n"))
                                }
                                
                                if let profileInfo = details.profileInfo {
                                    Text("プロフィール情報:")
                                        .font(.subheadline)
                                        .bold()
                                        .padding(.top)
                                    
                                    DetailRow(label: "Gender", value: profileInfo.gender ?? "N/A")
                                    DetailRow(label: "Age", value: profileInfo.age != nil ? "\(profileInfo.age!)" : "N/A")
                                    DetailRow(label: "Height", value: profileInfo.height != nil ? "\(profileInfo.height!)cm" : "N/A")
                                    DetailRow(label: "Birthday", value: profileInfo.birthday ?? "N/A")
                                }
                                
                                if let schedules = details.schedules {
                                    Text("スケジュール:")
                                        .font(.subheadline)
                                        .bold()
                                        .padding(.top)
                                    
                                    ForEach(schedules.indices, id: \.self) { index in
                                        let schedule = schedules[index]
                                        DetailRow(label: schedule.name, value: "Followers: \(schedule.followers ?? "N/A")")
                                    }
                                }
                            } else {
                                Text("詳細情報が利用できません")
                                    .foregroundColor(.secondary)
                                    .padding(.top)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: 400)
                }
            }
            .navigationTitle("ライバーデータデバッグ")
            .onAppear {
                Task {
                    await apiClient.fetchLivers()
                    
                    // 音乃遊羽を探す
                    if let otoneUuu = apiClient.livers.first(where: { $0.name.contains("音乃遊羽") || $0.name.contains("おとね") }) {
                        selectedLiver = otoneUuu
                        print("音乃遊羽が見つかりました: \(otoneUuu.name)")
                    } else {
                        // 最初のライバーを選択
                        selectedLiver = apiClient.livers.first
                        print("音乃遊羽が見つかりませんでした。利用可能なライバー:")
                        for liver in apiClient.livers.prefix(10) {
                            print("- \(liver.name)")
                        }
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 14))
                .padding(.bottom, 4)
        }
    }
}

#Preview {
    DebugLiverDataView()
}