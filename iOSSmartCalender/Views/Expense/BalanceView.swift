import SwiftUI

struct BalanceView: View {
    let expenses: FetchedResults<Expense>
    
    var body: some View {
        List {
            Section(header: Text("Current Balances")) {
                ForEach(calculateBalances(), id: \.person) { balance in
                    BalanceRow(balance: balance)
                }
            }
        }
    }
    
    private func calculateBalances() -> [PersonBalance] {
        var balances: [String: Double] = [:]
        
        for expense in expenses.filter({ !$0.isSettled }) {
            let amountPerPerson = expense.amountPerPerson
            
            // Payer gets credited
            balances[expense.payer, default: 0] += expense.amount - amountPerPerson
            
            // Participants get debited
            for participant in expense.participantsList {
                if participant != expense.payer {
                    balances[participant, default: 0] -= amountPerPerson
                }
            }
        }
        
        return balances.map { PersonBalance(person: $0.key, amount: $0.value) }
            .sorted { abs($0.amount) > abs($1.amount) }
    }
}

struct PersonBalance {
    let person: String
    let amount: Double
}

struct BalanceRow: View {
    let balance: PersonBalance
    
    var body: some View {
        HStack {
            Text(balance.person)
                .font(.headline)
            
            Spacer()
            
            if balance.amount > 0 {
                Text("Owed $\(balance.amount, specifier: "%.2f")")
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
            } else if balance.amount < 0 {
                Text("Owes $\(abs(balance.amount), specifier: "%.2f")")
                    .foregroundColor(.red)
                    .fontWeight(.semibold)
            } else {
                Text("Even")
                    .foregroundColor(.gray)
            }
        }
    }
}