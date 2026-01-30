import SwiftUI
import StoreKit

@main
struct CashoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appViewModel = AppViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appViewModel)
                .onChange(of: scenePhase) { newPhase in
                    handleScenePhaseChange(newPhase)
                }
        }
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            PushNotificationService.shared.clearBadgeCount()
        case .inactive, .background:
            break
        @unknown default:
            break
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var orientationManager = OrientationManager.shared
    
    var body: some View {
        Group {
            switch appViewModel.currentState {
            case .loading:
                LoadingView()
            case .content:
                if let address = appViewModel.remoteAddress {
                    ContentViewerScreen(remoteAddress: address)
                        .onAppear {
                            orientationManager.allowsRotation = true
                            requestReviewIfNeeded()
                        }
                }
            case .main:
                MainTabView()
                    .onAppear {
                        orientationManager.allowsRotation = false
                    }
            }
        }
        .onAppear {
            appViewModel.checkInitialState()
        }
    }
    
    private func requestReviewIfNeeded() {
        guard appViewModel.shouldRequestReview else { return }
        appViewModel.shouldRequestReview = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                
                Text("Cashory")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.2)
            }
        }
    }
}
