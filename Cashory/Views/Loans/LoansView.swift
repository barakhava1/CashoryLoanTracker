import SwiftUI

struct LoansView: View {
    @ObservedObject var viewModel: LoanViewModel
    @State private var showingAddLoan = false
    @State private var selectedFilter: LoanStatus? = nil
    
    var filteredLoans: [Loan] {
        if let filter = selectedFilter {
            return viewModel.loans.filter { $0.status == filter }
        }
        return viewModel.loans
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterPicker
                
                if filteredLoans.isEmpty {
                    emptyView
                } else {
                    loansList
                }
            }
            .navigationTitle("My Loans")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddLoan = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddLoan) {
                AddLoanView(viewModel: viewModel)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(title: "All", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }
                
                ForEach(LoanStatus.allCases, id: \.self) { status in
                    FilterChip(title: status.rawValue, isSelected: selectedFilter == status) {
                        selectedFilter = status
                    }
                }
            }
            .padding()
        }
    }
    
    private var loansList: some View {
        List {
            ForEach(filteredLoans) { loan in
                NavigationLink {
                    LoanDetailView(loan: loan, viewModel: viewModel)
                } label: {
                    LoanRowView(loan: loan)
                }
            }
            .onDelete { offsets in
                let loansToDelete = offsets.map { filteredLoans[$0] }
                for loan in loansToDelete {
                    viewModel.deleteLoan(loan)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Loans Found")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Add a new loan or change your filter")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button {
                showingAddLoan = true
            } label: {
                Label("Add Loan", systemImage: "plus")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct LoanRowView: View {
    let loan: Loan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(loan.name)
                    .font(.headline)
                
                Spacer()
                
                StatusBadge(status: loan.status)
            }
            
            HStack {
                Label(loan.type.rawValue, systemImage: loanTypeIcon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(loan.remainingAmount.currencyFormatted)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            ProgressView(value: progressValue)
                .tint(progressColor)
        }
        .padding(.vertical, 4)
    }
    
    private var loanTypeIcon: String {
        switch loan.type {
        case .personal: return "person.fill"
        case .mortgage: return "house.fill"
        case .auto: return "car.fill"
        case .student: return "graduationcap.fill"
        case .credit: return "creditcard.fill"
        case .other: return "doc.fill"
        }
    }
    
    private var progressValue: Double {
        guard loan.amount > 0 else { return 0 }
        return 1 - (loan.remainingAmount / loan.amount)
    }
    
    private var progressColor: Color {
        switch loan.status {
        case .active: return .blue
        case .paid: return .green
        case .overdue: return .red
        }
    }
}
