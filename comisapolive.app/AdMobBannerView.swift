import SwiftUI
import GoogleMobileAds

struct AdMobBannerView: View {
    let adUnitID: String
    
    var body: some View {
        BannerAd(adUnitID: adUnitID)
            .frame(width: 300, height: 250)
    }
}

private struct BannerAd: UIViewRepresentable {
    let adUnitID: String
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeMediumRectangle)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        bannerView.rootViewController = getRootViewController()
        bannerView.load(Request())
        return bannerView
    }
    
    func updateUIView(_ bannerView: BannerView, context: Context) {
        bannerView.rootViewController = getRootViewController()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        var parent: BannerAd
        
        init(_ parent: BannerAd) {
            self.parent = parent
        }
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("AdMob: Banner ad loaded successfully")
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("AdMob: Failed to load banner ad with error: \(error.localizedDescription)")
        }
        
        func bannerViewWillPresentScreen(_ bannerView: BannerView) {
            print("AdMob: Banner ad will present screen")
        }
        
        func bannerViewWillDismissScreen(_ bannerView: BannerView) {
            print("AdMob: Banner ad will dismiss screen")
        }
        
        func bannerViewDidDismissScreen(_ bannerView: BannerView) {
            print("AdMob: Banner ad did dismiss screen")
        }
    }
}

struct AdMobBannerView_Previews: PreviewProvider {
    static var previews: some View {
        AdMobBannerView(adUnitID: "ca-app-pub-5103020251808633/9942411882")
            .previewLayout(.sizeThatFits)
    }
}
