import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: LoanViewModel
    @Binding var currentTheme: AppTheme
    
    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        ThemeRow(
                            theme: theme,
                            isSelected: currentTheme == theme
                        ) {
                            currentTheme = theme
                            viewModel.updateTheme(theme)
                        }
                    }
                }
                
                Section("Statistics") {
                    StatRow(title: "Total Loans", value: "\(viewModel.loans.count)")
                    StatRow(title: "Active Loans", value: "\(viewModel.activeLoansCount)")
                    StatRow(title: "Paid Off", value: "\(viewModel.paidLoansCount)")
                    StatRow(title: "Total Debt", value: viewModel.totalDebt.currencyFormatted)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
    }
}

struct ThemeRow: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var icon: String {
        switch theme {
        case .system: return "gear"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 30)
                
                Text(theme.rawValue)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
        }
    }
}
