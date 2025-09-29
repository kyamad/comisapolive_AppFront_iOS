import SwiftUI

struct LiverDetails: View {
    let channelURL = URL(string: "https://www.youtube.com/channel/UCvycHCl3r3v_MYYPI_brTag")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    
                    Image("liver")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding(.top, 40)
                    
                    Text("姫咲 光妃 / Vtuber")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 5)
                    
                    HStack {
                        Text("活動場所")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Text("Youtube")
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    
                    HStack {
                        Text("チャンネル名")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Text("🌸姫咲 光妃🌸(ヒメサキ ミツキ)")
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 1)
                    
                    HStack {
                        Text("登録者数")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Text("230人")
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 1)
                    
                    HStack {
                        Text("口コミ評価")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        HStack(spacing: 5) {
                            ForEach(0..<5, id: \.self) { index in
                                Image(systemName: index < 5 ? "star.fill" : "star")
                                    .foregroundColor(index < 5 ? .yellow : .gray)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                    
                    Text("チャンネルを見に行く")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 25)
                        .onTapGesture {
                            UIApplication.shared.open(channelURL)
                        }
                    
                    Text("概       要")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 25)
                        .padding(.bottom, -5)
                    
                    Text("初めまして 姫咲光妃（ヒメサキ　ミツキ）といいます 4月より土曜日21時30分から配信予定 主に雑談や言ってほしいセリフや言葉もしくはゲーム配信していこうと思ってます V初めてなので至らないとことかありますがよろしくお願いします")
                        .padding(.horizontal, 15)
                        .padding(.top, 30)
                        .padding(.bottom, 30)
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0, green: 0.5, blue: 1).opacity(0.1))
                        .padding(.horizontal, 20)
                    
                    ReviewsView()
                        .padding(.vertical, 10)
                    
                    Text("チャンネルを見に行く")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 25)
                        .onTapGesture {
                            UIApplication.shared.open(channelURL)
                        }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 150)
            }
        }
    }
}

#Preview {
    LiverDetails()
}
