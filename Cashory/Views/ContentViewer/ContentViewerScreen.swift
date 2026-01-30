import SwiftUI

struct ContentViewerScreen: View {
    let remoteAddress: String
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            RemoteBrowser(address: remoteAddress, isLoading: $isLoading)
                .ignoresSafeArea()
            
            if isLoading {
                Color.black
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    }
            }
        }
        .statusBarHidden(true)
    }
}
