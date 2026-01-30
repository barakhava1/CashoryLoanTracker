import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = LoanViewModel()
    @State private var selectedTab = 0
    @State private var currentTheme: AppTheme = StorageManager.shared.selectedTheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }
                .tag(0)
            
            LoansView(viewModel: viewModel)
                .tabItem {
                    Label("Loans", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(1)
            
            HistoryView(viewModel: viewModel)
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)
            
            SettingsView(viewModel: viewModel, currentTheme: $currentTheme)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .preferredColorScheme(currentTheme.colorScheme)
    }
}
