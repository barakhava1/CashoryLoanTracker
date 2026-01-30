import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: LoanViewModel
    @State private var selectedLoanForPayment: Loan?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summarySection
                    
                    if !viewModel.activeLoans.isEmpty {
                        quickPaymentSection
                    }
                    
                    if !viewModel.loans.isEmpty {
                        recentLoansSection
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemGroupedBackground))
            .sheet(item: $selectedLoanForPayment) { loan in
                PaymentSheet(loan: loan, viewModel: viewModel) {
                    selectedLoanForPayment = nil
                }
            }
        }
    }
    
    private var summarySection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Debt",
                    value: viewModel.totalDebt.currencyFormatted,
                    icon: "creditcard.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Monthly Payment",
                    value: viewModel.totalMonthlyPayment.currencyFormatted,
                    icon: "calendar",
                    color: .orange
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Active Loans",
                    value: "\(viewModel.activeLoansCount)",
                    icon: "doc.text.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Paid Off",
                    value: "\(viewModel.paidLoansCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
    }
    
    private var quickPaymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Payment")
                .font(.headline)
                .padding(.horizontal, 4)
            
            ForEach(viewModel.activeLoans.prefix(3)) { loan in
                QuickPaymentCard(loan: loan) {
                    selectedLoanForPayment = loan
                }
            }
        }
    }
    
    private var recentLoansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Loans")
                .font(.headline)
                .padding(.horizontal, 4)
            
            ForEach(viewModel.loans.prefix(3)) { loan in
                LoanCard(loan: loan)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Loans Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your first loan to start tracking your finances")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}

struct QuickPaymentCard: View {
    let loan: Loan
    let onPayTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(loan.name)
                    .font(.headline)
                
                Text("Due: \(loan.calculatedMonthlyPayment.currencyFormatted)/mo")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                onPayTap()
            } label: {
                Text("Pay")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct LoanCard: View {
    let loan: Loan
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(loan.name)
                    .font(.headline)
                
                Text(loan.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(loan.remainingAmount.currencyFormatted)
                    .font(.headline)
                
                StatusBadge(status: loan.status)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct StatusBadge: View {
    let status: LoanStatus
    
    var color: Color {
        switch status {
        case .active: return .blue
        case .paid: return .green
        case .overdue: return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

extension Double {
    var currencyFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}
