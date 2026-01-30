import Foundation
import SwiftUI
import Combine

final class LoanViewModel: ObservableObject {
    @Published var loans: [Loan] = []
    @Published var selectedTheme: AppTheme = .system
    
    private let storage = StorageManager.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        loans = storage.savedLoans
        selectedTheme = storage.selectedTheme
    }
    
    func addLoan(_ loan: Loan) {
        loans.append(loan)
        saveLoans()
    }
    
    func updateLoan(_ loan: Loan) {
        if let index = loans.firstIndex(where: { $0.id == loan.id }) {
            loans[index] = loan
            saveLoans()
        }
    }
    
    func deleteLoan(_ loan: Loan) {
        loans.removeAll { $0.id == loan.id }
        saveLoans()
    }
    
    func deleteLoan(at offsets: IndexSet) {
        loans.remove(atOffsets: offsets)
        saveLoans()
    }
    
    func makePayment(for loan: Loan, amount: Double) {
        guard let index = loans.firstIndex(where: { $0.id == loan.id }) else { return }
        
        var updatedLoan = loans[index]
        updatedLoan.remainingAmount = max(0, updatedLoan.remainingAmount - amount)
        
        if updatedLoan.remainingAmount == 0 {
            updatedLoan.markAsPaid()
        }
        
        loans[index] = updatedLoan
        saveLoans()
    }
    
    func saveLoans() {
        storage.savedLoans = loans
    }
    
    func updateTheme(_ theme: AppTheme) {
        selectedTheme = theme
        storage.selectedTheme = theme
    }
    
    var totalDebt: Double {
        loans.filter { $0.status == .active }.reduce(0) { $0 + $1.remainingAmount }
    }
    
    var totalMonthlyPayment: Double {
        loans.filter { $0.status == .active }.reduce(0) { $0 + $1.calculatedMonthlyPayment }
    }
    
    var activeLoansCount: Int {
        loans.filter { $0.status == .active }.count
    }
    
    var paidLoansCount: Int {
        loans.filter { $0.status == .paid }.count
    }
    
    var activeLoans: [Loan] {
        loans.filter { $0.status == .active }
    }
}
