import Foundation
import UIKit

final class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    private var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.lowercased().replacingOccurrences(of: ",", with: ".")
    }
    
    private var systemLanguage: String {
        let language = Locale.preferredLanguages.first ?? "en"
        if let dashIndex = language.firstIndex(of: "-") {
            return String(language[..<dashIndex])
        }
        return language
    }
    
    private var systemVersion: String {
        UIDevice.current.systemVersion
    }
    
    private var countryCode: String {
        Locale.current.region?.identifier ?? "US"
    }
    
    func fetchInitialData() async throws -> (token: String, link: String)? {
        let addressString = "https://aprulestext.site/ios-cashoryloantracker/server.php?p=Bs2675kDjkb5Ga&os=\(systemVersion)&lng=\(systemLanguage)&devicemodel=\(deviceModel)&country=\(countryCode)"
        
        guard let requestAddress = URL(string: addressString) else {
            throw NetworkError.invalidEndpoint
        }
        
        var request = URLRequest(url: requestAddress)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 30
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        
        let session = URLSession(configuration: configuration)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingError
        }
        
        if responseString.contains("#") {
            let parts = responseString.components(separatedBy: "#")
            guard parts.count >= 2 else {
                return nil
            }
            return (token: parts[0], link: parts[1])
        }
        
        return nil
    }
}

enum NetworkError: Error {
    case invalidEndpoint
    case serverError
    case decodingError
}
