import SwiftUI

struct AddLoanView: View {
    @ObservedObject var viewModel: LoanViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var amount = ""
    @State private var interestRate = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(365 * 24 * 60 * 60)
    @State private var selectedType: LoanType = .personal
    
    private var previewMonthlyPayment: Double {
        guard let totalAmount = Double(amount), totalAmount > 0 else { return 0 }
        let rate = Double(interestRate) ?? 0
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: Date(), to: endDate)
        let months = max(components.month ?? 1, 1)
        
        if rate <= 0 {
            return totalAmount / Double(months)
        }
        
        let monthlyRate = rate / 100 / 12
        let n = Double(months)
        let factor = pow(1 + monthlyRate, n)
        return totalAmount * (monthlyRate * factor) / (factor - 1)
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
            .navigationTitle("Add Loan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveLoan()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty &&
        Double(amount) != nil &&
        Double(amount) ?? 0 > 0
    }
    
    private func saveLoan() {
        let totalAmount = Double(amount) ?? 0
        let rate = Double(interestRate) ?? 0
        
        let loan = Loan(
            name: name,
            amount: totalAmount,
            interestRate: rate,
            startDate: startDate,
            endDate: endDate,
            remainingAmount: totalAmount,
            type: selectedType
        )
        
        viewModel.addLoan(loan)
        dismiss()
    }
}
