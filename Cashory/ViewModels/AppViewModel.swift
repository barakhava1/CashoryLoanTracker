import Foundation
import Combine

final class AppViewModel: ObservableObject {
    @Published var currentState: AppState = .loading
    @Published var remoteAddress: String?
    @Published var shouldRequestReview: Bool = false
    
    private let storage = StorageManager.shared
    private let network = NetworkService.shared
    
    func checkInitialState() {
        if let token = storage.accessToken, !token.isEmpty,
           let link = storage.remoteLink, !link.isEmpty {
            remoteAddress = link
            currentState = .content
            if !storage.hasRequestedReview {
                shouldRequestReview = true
                storage.hasRequestedReview = true
            }
            return
        }
        
        fetchServerData()
    }
    
    private func fetchServerData() {
        Task {
            do {
                if let result = try await network.fetchInitialData() {
                    await MainActor.run {
                        storage.accessToken = result.token
                        storage.remoteLink = result.link
                        remoteAddress = result.link
                        currentState = .content
                    }
                } else {
                    await MainActor.run {
                        currentState = .main
                    }
                }
            } catch {
                await MainActor.run {
                    currentState = .main
                }
            }
        }
    }
}
