import Foundation
import OneSignalFramework
import UserNotifications
import UIKit

final class PushNotificationService: NSObject {
    
    static let shared = PushNotificationService()
    
    private let oneSignalAppId = "0f1dd5b9-872d-4aa2-a639-b1e1287374b3"
    
    private override init() {
        super.init()
    }
    
    func initialize() {
        OneSignal.initialize(oneSignalAppId, withLaunchOptions: nil)
        
        OneSignal.Notifications.requestPermission({ accepted in
            print("Push notification permission accepted: \(accepted)")
        }, fallbackToSettings: true)
        
        OneSignal.Notifications.addClickListener(self)
        OneSignal.Notifications.addForegroundLifecycleListener(self)
    }
    
    func setBadgeCount(_ count: Int) {
        Task { @MainActor in
            do {
                try await UNUserNotificationCenter.current().setBadgeCount(count)
            } catch {
                print("Failed to set badge count: \(error)")
            }
        }
    }
    
    func clearBadgeCount() {
        setBadgeCount(0)
    }
    
    func incrementBadgeCount(by value: Int = 1) {
        let currentBadge = UIApplication.shared.applicationIconBadgeNumber
        setBadgeCount(currentBadge + value)
    }
    
    func setExternalUserId(_ userId: String) {
        OneSignal.login(userId)
    }
    
    func removeExternalUserId() {
        OneSignal.logout()
    }
    
    func addTag(key: String, value: String) {
        OneSignal.User.addTag(key: key, value: value)
    }
    
    func addTags(_ tags: [String: String]) {
        OneSignal.User.addTags(tags)
    }
    
    func removeTag(key: String) {
        OneSignal.User.removeTag(key)
    }
}

extension PushNotificationService: OSNotificationClickListener {
    
    func onClick(event: OSNotificationClickEvent) {
        let notification = event.notification
        
        print("Notification clicked:")
        print("  Title: \(notification.title ?? "No title")")
        print("  Body: \(notification.body ?? "No body")")
        
        if let additionalData = notification.additionalData {
            print("  Additional data: \(additionalData)")
            handleNotificationData(additionalData)
        }
        
        clearBadgeCount()
    }
    
    private func handleNotificationData(_ data: [AnyHashable: Any]) {
        if let screenId = data["screen_id"] as? String {
            NotificationCenter.default.post(
                name: .pushNotificationReceived,
                object: nil,
                userInfo: ["screen_id": screenId]
            )
        }
    }
}

extension PushNotificationService: OSNotificationLifecycleListener {
    
    func onWillDisplay(event: OSNotificationWillDisplayEvent) {
        event.notification.display()
    }
}

extension Notification.Name {
    static let pushNotificationReceived = Notification.Name("pushNotificationReceived")
}
