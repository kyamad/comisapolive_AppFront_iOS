import SwiftUI

struct ConditionalAdView: View {
    let adUnitID: String
    @StateObject private var adManager = AdFrequencyManager()
    @State private var showAd: Bool = false
    
    var body: some View {
        VStack {
            if showAd {
                VStack {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 2)
                        .padding(.bottom, 5)
                        .offset(y: -2)
                    
                    AdMobBannerView(adUnitID: adUnitID)
                        .padding()
                    
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 2)
                        .padding(.top, 5)
                }
                .padding(.bottom, -7)
            }
        }
        .onAppear {
            showAd = adManager.shouldShowAd()
        }
    }
}