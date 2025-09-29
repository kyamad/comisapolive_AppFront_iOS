import SwiftUI
import WebKit
import AVFoundation
import Photos

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let coordinator = context.coordinator
        
        let configuration = WKWebViewConfiguration()
        // ファイルアップロードを有効にする
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        configuration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
        
#if os(macOS)
        // macOS専用のファイル選択ダイアログ
        @available(macOS 10.12, *)
        func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
            // macOS実装はここに追加可能
            completionHandler(nil)
        }
#endif
        
        // iOS/iPadOS専用のJavaScriptアラート処理でファイル選択を実装
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            
            // ファイル選択のメッセージかチェック
            if message.contains("file") || message.contains("photo") || message.contains("選択") {
                
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootViewController = windowScene.windows.first?.rootViewController else {
                    completionHandler()
                    return
                }
                
                let alertController = UIAlertController(title: "写真を選択", message: nil, preferredStyle: .actionSheet)
                
                // カメラで撮影
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    alertController.addAction(UIAlertAction(title: "カメラで撮影", style: .default) { _ in
                        self.requestCameraPermission { granted in
                            if granted {
                                self.presentImagePickerForJavaScript(sourceType: .camera, from: rootViewController, webView: webView)
                            } else {
                                self.showPermissionAlert(for: "カメラ", from: rootViewController)
                            }
                            completionHandler()
                        }
                    })
                }
                
                // フォトライブラリから選択
                alertController.addAction(UIAlertAction(title: "フォトライブラリから選択", style: .default) { _ in
                    self.requestPhotoLibraryPermission { granted in
                        if granted {
                            self.presentImagePickerForJavaScript(sourceType: .photoLibrary, from: rootViewController, webView: webView)
                        } else {
                            self.showPermissionAlert(for: "フォトライブラリ", from: rootViewController)
                        }
                        completionHandler()
                    }
                })
                
                alertController.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                    completionHandler()
                })
                
                // iPadでのpopover設定
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = webView
                    popoverController.sourceRect = CGRect(x: webView.bounds.midX, y: webView.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                rootViewController.present(alertController, animated: true)
                
            } else {
                // 通常のアラート処理
                let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    completionHandler()
                })
                
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootViewController = windowScene.windows.first?.rootViewController else {
                    completionHandler()
                    return
                }
                
                rootViewController.present(alertController, animated: true)
            }
        }
        
        // カメラ権限の確認
        private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                completion(true)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            default:
                completion(false)
            }
        }
        
        // フォトライブラリ権限の確認
        private func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized, .limited:
                completion(true)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        completion(status == .authorized || status == .limited)
                    }
                }
            default:
                completion(false)
            }
        }
        
        // JavaScript用の画像ピッカーの表示
        private func presentImagePickerForJavaScript(sourceType: UIImagePickerController.SourceType, from viewController: UIViewController, webView: WKWebView) {
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                return
            }
            
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.mediaTypes = ["public.image"]
            picker.allowsEditing = true
            
            let coordinator = JavaScriptImagePickerCoordinator(webView: webView)
            picker.delegate = coordinator
            
            // coordinatorを保持
            objc_setAssociatedObject(picker, "coordinator", coordinator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            viewController.present(picker, animated: true)
        }
        
        // 従来の画像ピッカーの表示（互換性のため残しておく）
        private func presentImagePicker(sourceType: UIImagePickerController.SourceType, from viewController: UIViewController, completionHandler: @escaping ([URL]?) -> Void) {
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                completionHandler(nil)
                return
            }
            
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.mediaTypes = ["public.image"]
            picker.allowsEditing = true
            
            let coordinator = ImagePickerCoordinator(completionHandler: completionHandler)
            picker.delegate = coordinator
            
            // coordinatorを保持
            objc_setAssociatedObject(picker, "coordinator", coordinator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            viewController.present(picker, animated: true)
        }
        
        // 権限拒否時のアラート表示
        private func showPermissionAlert(for feature: String, from viewController: UIViewController) {
            let alert = UIAlertController(
                title: "\(feature)へのアクセスが必要です",
                message: "設定から\(feature)へのアクセスを許可してください。",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "設定を開く", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
            
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
            
            viewController.present(alert, animated: true)
        }
    }
}

// JavaScript用画像ピッカーのデリゲート処理
class JavaScriptImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private weak var webView: WKWebView?
    
    init(webView: WKWebView) {
        self.webView = webView
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage else {
            return
        }
        
        // 画像をBase64エンコードしてJavaScriptに渡す
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            let javascript = "if(window.handleImageSelected) { window.handleImageSelected('data:image/jpeg;base64,\(base64String)'); }"
            
            DispatchQueue.main.async {
                self.webView?.evaluateJavaScript(javascript) { result, error in
                    if let error = error {
                        print("JavaScript error: \(error)")
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        // キャンセル時のJavaScript処理
        let javascript = "if(window.handleImageCancelled) { window.handleImageCancelled(); }"
        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript(javascript, completionHandler: nil)
        }
    }
}

// 画像ピッカーのデリゲート処理（従来版）
class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let completionHandler: ([URL]?) -> Void
    
    init(completionHandler: @escaping ([URL]?) -> Void) {
        self.completionHandler = completionHandler
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage else {
            completionHandler(nil)
            return
        }
        
        // 画像を一時ファイルとして保存
        saveImageToTemporaryFile(image) { [weak self] url in
            self?.completionHandler(url != nil ? [url!] : nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        completionHandler(nil)
    }
    
    private func saveImageToTemporaryFile(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = "photo_\(Date().timeIntervalSince1970).jpg"
            let tempURL = tempDirectory.appendingPathComponent(fileName)
            
            do {
                try imageData.write(to: tempURL)
                DispatchQueue.main.async {
                    completion(tempURL)
                }
            } catch {
                print("Error saving image: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

struct WebViewContainer: View {
    let url: URL

    var body: some View {
        WebView(url: url)
            .edgesIgnoringSafeArea(.all) // フルスクリーン表示
            .navigationBarTitle("", displayMode: .inline) // ナビゲーションバーのタイトル設定
    }
}
