import UIKit
import SwiftUI
import Combine

final class OrientationManager: ObservableObject {
    static let shared = OrientationManager()
    
    @Published var allowsRotation: Bool = false {
        didSet {
            updateOrientation()
        }
    }
    
    private init() {}
    
    private func updateOrientation() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let orientations: UIInterfaceOrientationMask = allowsRotation ? .all : .portrait
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientations))
        windowScene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if OrientationManager.shared.allowsRotation {
            return .all
        }
        return .portrait
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
