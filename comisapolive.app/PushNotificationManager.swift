import UIKit
import UserNotifications

final class PushNotificationManager {
    static let shared = PushNotificationManager()

    private init() {}

    func registerForPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("[Push] Notification authorization error: \(error.localizedDescription)")
                return
            }

            guard granted else {
                print("[Push] Notification authorization declined by user")
                return
            }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

