import SwiftUI
import SafariServices

struct MypageView: View {
    @State private var showingSafari = false
    
    var body: some View {
        VStack {
            Button(action: {
                showingSafari = true
            }) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                    Text("マイページ")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("マイページ")
        .sheet(isPresented: $showingSafari) {
            SafariView(url: URL(string: "https://www.comisapolive.com/mypage/")!)
        }
    }
}

#Preview {
    MypageView()
}
