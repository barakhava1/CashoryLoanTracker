import SwiftUI
import WebKit

struct RemoteBrowser: UIViewRepresentable {
    let address: String
    @Binding var isLoading: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        configuration.websiteDataStore = .nonPersistent()
        
        let browser = WKWebView(frame: .zero, configuration: configuration)
        browser.navigationDelegate = context.coordinator
        browser.allowsBackForwardNavigationGestures = true
        browser.scrollView.bounces = true
        browser.scrollView.contentInsetAdjustmentBehavior = .never
        browser.isOpaque = false
        browser.backgroundColor = .black
        
        return browser
    }
    
    func updateUIView(_ browser: WKWebView, context: Context) {
        guard let destination = URL(string: address) else { return }
        
        if browser.url == nil {
            var request = URLRequest(url: destination)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            browser.load(request)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: RemoteBrowser
        private var initialLoadComplete = false
        
        init(_ parent: RemoteBrowser) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if !initialLoadComplete {
                DispatchQueue.main.async {
                    self.parent.isLoading = true
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if !initialLoadComplete {
                initialLoadComplete = true
                DispatchQueue.main.async {
                    self.parent.isLoading = false
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if !initialLoadComplete {
                initialLoadComplete = true
                DispatchQueue.main.async {
                    self.parent.isLoading = false
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            if !initialLoadComplete {
                initialLoadComplete = true
                DispatchQueue.main.async {
                    self.parent.isLoading = false
                }
            }
        }
    }
}
