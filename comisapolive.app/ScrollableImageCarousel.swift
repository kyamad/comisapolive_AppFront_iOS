import SwiftUI

struct ScrollableImageCarousel: View {
    @Binding var scrollPosition: Int
    let totalItems: Int
    let onImageTap: () -> Void

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 60) {
                        if totalItems > 0 {
                            ForEach(0..<totalItems, id: \.self) { index in
                                ScrollableImageItem()
                                    .id(index)
                                    .onTapGesture {
                                        onImageTap()
                                    }
                            }
                        } else {
                            Text("画像がありません")
                                .foregroundColor(.gray)
                                .font(.headline)
                        }
                    }
                    .padding(.horizontal, 80)
                    .padding(.top, 5)
                    .padding(.bottom, 15)
                }
                .frame(height: 270)
                .background(Color(red: 96/255, green: 212/255, blue: 200/255))
                .padding(.bottom, 10)
                .onChange(of: scrollPosition) { newIndex in
                    if newIndex >= 0 && newIndex < totalItems {
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
            }

            HStack {
                Button(action: {
                    if scrollPosition > 0 {
                        scrollPosition -= 1
                    }
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                        .padding()
                }
                .opacity(scrollPosition == 0 ? 0.3 : 1)
                .disabled(scrollPosition == 0)
                .zIndex(1)
                .padding(.leading, 10)

                Spacer()

                Button(action: {
                    if scrollPosition < totalItems - 1 {
                        scrollPosition += 1
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                        .padding()
                }
                .opacity(scrollPosition == totalItems - 1 ? 0.3 : 1)
                .disabled(scrollPosition == totalItems - 1)
                .zIndex(1)
                .padding(.trailing, 10)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
