import SwiftUI

struct EditLoanView: View {
    @Binding var loan: Loan
    @ObservedObject var viewModel: LoanViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var remainingAmount: String = ""
    @State private var interestRate: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var selectedType: LoanType = .personal
    
    private var previewMonthlyPayment: Double {
        guard let remaining = Double(remainingAmount), remaining > 0 else { return 0 }
        let rate = Double(interestRate) ?? 0
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: Date(), to: endDate)
        let months = max(components.month ?? 1, 1)
        
        if rate <= 0 {
            return remaining / Double(months)
        }
        
        let monthlyRate = rate / 100 / 12
        let n = Double(months)
        let factor = pow(1 + monthlyRate, n)
        return remaining * (monthlyRate * factor) / (factor - 1)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Loan Details") {
                    TextField("Loan Name", text: $name)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(LoanType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section("Financial Info") {
                    HStack {
                        Text("$")
                        TextField("Total Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("$")
                        TextField("Remaining Amount", text: $remainingAmount)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        TextField("Interest Rate", text: $interestRate)
                            .keyboardType(.decimalPad)
                        Text("%")
                    }
                }
                
                Section("Dates") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                if previewMonthlyPayment > 0 {
                    Section("Calculated Payment") {
                        HStack {
                            Text("Monthly Payment")
                            Spacer()
                            Text(previewMonthlyPayment.currencyFormatted)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("Edit Loan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadLoanData()
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty &&
        Double(amount) != nil &&
        Double(amount) ?? 0 > 0
    }
    
    private func loadLoanData() {
        name = loan.name
        amount = String(loan.amount)
        remainingAmount = String(loan.remainingAmount)
        interestRate = String(loan.interestRate)
        startDate = loan.startDate
        endDate = loan.endDate
        selectedType = loan.type
    }
    
    private func saveChanges() {
        loan.name = name
        loan.amount = Double(amount) ?? 0
        loan.remainingAmount = Double(remainingAmount) ?? 0
        loan.interestRate = Double(interestRate) ?? 0
        loan.startDate = startDate
        loan.endDate = endDate
        loan.type = selectedType
        
        viewModel.updateLoan(loan)
        dismiss()
    }
}
