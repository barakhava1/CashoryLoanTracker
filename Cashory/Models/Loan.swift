import Foundation

struct Loan: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var interestRate: Double
    var startDate: Date
    var endDate: Date
    var remainingAmount: Double
    var type: LoanType
    private var _status: LoanStatus
    
    var status: LoanStatus {
        if _status == .paid || remainingAmount <= 0 {
            return .paid
        }
        if endDate < Date() && remainingAmount > 0 {
            return .overdue
        }
        return .active
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        interestRate: Double,
        startDate: Date,
        endDate: Date,
        remainingAmount: Double,
        type: LoanType,
        status: LoanStatus = .active
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.interestRate = interestRate
        self.startDate = startDate
        self.endDate = endDate
        self.remainingAmount = remainingAmount
        self.type = type
        self._status = status
    }
    
    mutating func markAsPaid() {
        _status = .paid
        remainingAmount = 0
    }
    
    var monthsRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: Date(), to: endDate)
        return max(components.month ?? 1, 1)
    }
    
    var calculatedMonthlyPayment: Double {
        guard remainingAmount > 0, monthsRemaining > 0 else { return 0 }
        
        if interestRate <= 0 {
            return remainingAmount / Double(monthsRemaining)
        }
        
        let monthlyRate = interestRate / 100 / 12
        let n = Double(monthsRemaining)
        let factor = pow(1 + monthlyRate, n)
        return remainingAmount * (monthlyRate * factor) / (factor - 1)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, amount, interestRate, startDate, endDate, remainingAmount, type
        case _status = "status"
    }
}

enum LoanType: String, Codable, CaseIterable {
    case personal = "Personal"
    case mortgage = "Mortgage"
    case auto = "Auto"
    case student = "Student"
    case credit = "Credit Card"
    case other = "Other"
}

enum LoanStatus: String, Codable, CaseIterable {
    case active = "Active"
    case paid = "Paid Off"
    case overdue = "Overdue"
}
