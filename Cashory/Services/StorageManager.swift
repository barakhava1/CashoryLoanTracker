import Foundation

final class StorageManager {
    static let shared = StorageManager()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let accessToken = "access_token_key"
        static let remoteLink = "remote_link_key"
        static let selectedTheme = "selected_theme_key"
        static let savedLoans = "saved_loans_key"
        static let hasRequestedReview = "has_requested_review_key"
    }
    
    private init() {}
    
    var accessToken: String? {
        get { defaults.string(forKey: Keys.accessToken) }
        set { defaults.set(newValue, forKey: Keys.accessToken) }
    }
    
    var remoteLink: String? {
        get { defaults.string(forKey: Keys.remoteLink) }
        set { defaults.set(newValue, forKey: Keys.remoteLink) }
    }
    
    var hasRequestedReview: Bool {
        get { defaults.bool(forKey: Keys.hasRequestedReview) }
        set { defaults.set(newValue, forKey: Keys.hasRequestedReview) }
    }
    
    var selectedTheme: AppTheme {
        get {
            guard let raw = defaults.string(forKey: Keys.selectedTheme),
                  let theme = AppTheme(rawValue: raw) else {
                return .system
            }
            return theme
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.selectedTheme)
        }
    }
    
    var savedLoans: [Loan] {
        get {
            guard let data = defaults.data(forKey: Keys.savedLoans),
                  let loans = try? JSONDecoder().decode([Loan].self, from: data) else {
                return []
            }
            return loans
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.savedLoans)
            }
        }
    }
    
    func clearSession() {
        defaults.removeObject(forKey: Keys.accessToken)
        defaults.removeObject(forKey: Keys.remoteLink)
    }
}
