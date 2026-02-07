import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: LoanViewModel
    
    var paidLoans: [Loan] {
        viewModel.loans.filter { $0.status == .paid }
    }
    
    var overdueLoans: [Loan] {
        viewModel.loans.filter { $0.status == .overdue }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !paidLoans.isEmpty {
                    Section("Paid Off") {
                        ForEach(paidLoans) { loan in
                            HistoryRow(loan: loan)
                        }
                    }
                }
                
                if !overdueLoans.isEmpty {
                    Section("Overdue") {
                        ForEach(overdueLoans) { loan in
                            HistoryRow(loan: loan)
                        }
                    }
                }
                
                if paidLoans.isEmpty && overdueLoans.isEmpty {
                    Section {
                        VStack(spacing: 16) {
                            Image(systemName: "clock.badge.checkmark")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text("No History Yet")
                                .font(.headline)
                            
                            Text("Paid off and overdue loans will appear here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("History")
        }
    }
}

struct HistoryRow: View {
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
                Text(loan.amount.currencyFormatted)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(loan.endDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
