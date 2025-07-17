import SwiftUI
import CoreData

struct ExpenseTrackerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.createdAt, ascending: false)],
        animation: .default)
    private var expenses: FetchedResults<Expense>
    
    @State private var showingAddExpense = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("View", selection: $selectedTab) {
                    Text("Expenses").tag(0)
                    Text("Balances").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
                    ExpenseListView(expenses: expenses)
                } else {
                    BalanceView(expenses: expenses)
                }
            }
            .navigationTitle("Expense Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
        }
    }
}

struct ExpenseListView: View {
    let expenses: FetchedResults<Expense>
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        List {
            ForEach(expenses, id: \.id) { expense in
                ExpenseRow(expense: expense)
            }
            .onDelete(perform: deleteExpenses)
        }
    }
    
    private func deleteExpenses(offsets: IndexSet) {
        withAnimation {
            offsets.map { expenses[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    Text(expense.title)
                        .font(.headline)
                    Text(expense.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("$\(expense.amount, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(expense.isSettled ? .green : .primary)
                    
                    Button(expense.isSettled ? "Settled" : "Mark Settled") {
                        toggleSettled()
                    }
                    .font(.caption)
                    .foregroundColor(expense.isSettled ? .green : .blue)
                }
            }
            
            HStack {
                Text("Paid by: \(expense.payer)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Split: \(expense.participantsList.count) people")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !expense.participantsList.isEmpty {
                Text("Participants: \(expense.participantsList.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 2)
        .opacity(expense.isSettled ? 0.6 : 1.0)
    }
    
    private func toggleSettled() {
        expense.isSettled.toggle()
        try? viewContext.save()
    }
}