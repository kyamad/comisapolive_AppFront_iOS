import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        configuration.barCollapsingEnabled = true
        
        let safariViewController = SFSafariViewController(url: url, configuration: configuration)
        safariViewController.delegate = context.coordinator
        
        // カスタマイズ
        safariViewController.preferredBarTintColor = UIColor.systemBackground
        safariViewController.preferredControlTintColor = UIColor.systemBlue
        
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // 更新が必要な場合はここで処理
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: SafariView
        
        init(_ parent: SafariView) {
            self.parent = parent
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct SafariViewContainer: View {
    let url: URL
    @State private var showingSafari = false
    
    var body: some View {
        VStack {
            Button("ページを開く") {
                showingSafari = true
            }
            .padding()
        }
        .sheet(isPresented: $showingSafari) {
            SafariView(url: url)
        }
    }
}

// プレビュー用
struct SafariView_Previews: PreviewProvider {
    static var previews: some View {
        SafariViewContainer(url: URL(string: "https://www.comisapolive.com/mypage/")!)
    }
}