import SwiftUI

struct LoanDetailView: View {
    @State var loan: Loan
    @ObservedObject var viewModel: LoanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingPaymentSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                financialSection
                datesSection
                actionsSection
            }
            .padding()
        }
        .navigationTitle(loan.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditLoanView(loan: $loan, viewModel: viewModel)
        }
        .sheet(isPresented: $showingPaymentSheet) {
            PaymentSheet(loan: loan, viewModel: viewModel) {
                if let updated = viewModel.loans.first(where: { $0.id == loan.id }) {
                    loan = updated
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: loanIcon)
                .font(.system(size: 50))
                .foregroundColor(.accentColor)
            
            Text(loan.type.rawValue)
                .font(.headline)
                .foregroundColor(.secondary)
            
            StatusBadge(status: loan.status)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var financialSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Financial Details")
                .font(.headline)
            
            DetailRow(title: "Original Amount", value: loan.amount.currencyFormatted)
            DetailRow(title: "Remaining", value: loan.remainingAmount.currencyFormatted)
            DetailRow(title: "Interest Rate", value: String(format: "%.2f%%", loan.interestRate))
            DetailRow(title: "Monthly Payment", value: loan.calculatedMonthlyPayment.currencyFormatted)
            DetailRow(title: "Months Remaining", value: "\(loan.monthsRemaining)")
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.1f%%", progressPercentage))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: progressValue)
                    .tint(.green)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Timeline")
                .font(.headline)
            
            DetailRow(title: "Start Date", value: loan.startDate.formatted(date: .abbreviated, time: .omitted))
            DetailRow(title: "End Date", value: loan.endDate.formatted(date: .abbreviated, time: .omitted))
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            if loan.status == .active {
                Button {
                    showingPaymentSheet = true
                } label: {
                    Label("Make Payment", systemImage: "dollarsign.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    markAsPaid()
                } label: {
                    Label("Mark as Paid", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            
            Button(role: .destructive) {
                deleteLoan()
            } label: {
                Label("Delete Loan", systemImage: "trash.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var loanIcon: String {
        switch loan.type {
        case .personal: return "person.crop.circle.fill"
        case .mortgage: return "house.circle.fill"
        case .auto: return "car.circle.fill"
        case .student: return "graduationcap.circle.fill"
        case .credit: return "creditcard.circle.fill"
        case .other: return "doc.circle.fill"
        }
    }
    
    private var progressValue: Double {
        guard loan.amount > 0 else { return 0 }
        return 1 - (loan.remainingAmount / loan.amount)
    }
    
    private var progressPercentage: Double {
        progressValue * 100
    }
    
    private func markAsPaid() {
        loan.markAsPaid()
        viewModel.updateLoan(loan)
    }
    
    private func deleteLoan() {
        viewModel.deleteLoan(loan)
        dismiss()
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct PaymentSheet: View {
    let loan: Loan
    @ObservedObject var viewModel: LoanViewModel
    var onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var paymentAmount = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Loan")
                        Spacer()
                        Text(loan.name)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Remaining")
                        Spacer()
                        Text(loan.remainingAmount.currencyFormatted)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Suggested Payment")
                        Spacer()
                        Text(loan.calculatedMonthlyPayment.currencyFormatted)
                            .foregroundColor(.accentColor)
                            .fontWeight(.medium)
                    }
                }
                
                Section("Payment Amount") {
                    HStack {
                        Text("$")
                        TextField("Amount", text: $paymentAmount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Button("Use Suggested Amount") {
                        paymentAmount = String(format: "%.2f", loan.calculatedMonthlyPayment)
                    }
                    .font(.subheadline)
                }
                
                if let amount = Double(paymentAmount), amount > 0 {
                    Section("After Payment") {
                        let newRemaining = max(0, loan.remainingAmount - amount)
                        HStack {
                            Text("New Remaining")
                            Spacer()
                            Text(newRemaining.currencyFormatted)
                                .fontWeight(.medium)
                                .foregroundColor(newRemaining == 0 ? .green : .primary)
                        }
                    }
                }
            }
            .navigationTitle("Make Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Pay") {
                        makePayment()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard let amount = Double(paymentAmount) else { return false }
        return amount > 0 && amount <= loan.remainingAmount
    }
    
    private func makePayment() {
        guard let amount = Double(paymentAmount) else { return }
        viewModel.makePayment(for: loan, amount: amount)
        onComplete()
        dismiss()
    }
}
