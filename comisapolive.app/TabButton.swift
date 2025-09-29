import SwiftUI

struct TabButton: View {
    let index: Int
    @Binding var selectedTab: Int
    let text: String
    let imageName: String
    let backgroundColor: Color
    
    private let screenWidth = UIScreen.main.bounds.width // ✅ 画面の横幅を取得

    var body: some View {
        Button(action: {
            withAnimation {
                selectedTab = index
            }
        }) {
            HStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.bottom, 35)
                
                Text(text)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 35)
            }
            .padding()
            .frame(width: screenWidth / 1.5, height: 95)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.black, lineWidth: 2)
            )
            .zIndex(selectedTab == index ? 1 : 0)
        }
    }
}





#Preview {
    ContentView()
}
