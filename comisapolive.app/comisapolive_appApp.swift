//
//  comisapolive_appApp.swift
//  comisapolive.app
//
//  Created by 山田光世 on 2025/03/06.
//

import SwiftUI
import GoogleMobileAds

@main
struct comisapolive_appApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        MobileAds.shared.start { status in
            print("AdMob SDK initialized with status: \(status)")
            print("AdMob adapter statuses:")
            for adapter in status.adapterStatusesByClassName {
                print("- \(adapter.key): \(adapter.value.state.rawValue)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TopView()
        }
    }
}
