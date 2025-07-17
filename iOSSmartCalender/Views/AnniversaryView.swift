import SwiftUI
import CoreData

struct AnniversaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Anniversary.date, ascending: true)],
        animation: .default)
    private var anniversaries: FetchedResults<Anniversary>
    
    @State private var showingAddAnniversary = false
    
    var body: some View {
        NavigationView {
            List {
                if !anniversaries.isEmpty {
                    Section(header: Text("Upcoming")) {
                        ForEach(upcomingAnniversaries, id: \.id) { anniversary in
                            AnniversaryRow(anniversary: anniversary, showCountdown: true)
                        }
                    }
                    
                    Section(header: Text("All Anniversaries")) {
                        ForEach(anniversaries, id: \.id) { anniversary in
                            AnniversaryRow(anniversary: anniversary, showCountdown: false)
                        }
                        .onDelete(perform: deleteAnniversaries)
                    }
                } else {
                    VStack {
                        Image(systemName: "heart")
                            .font(.system(size: 50))
                            .foregroundColor(.pink)
                        Text("No anniversaries yet")
                            .foregroundColor(.gray)
                        Text("Add your special dates!")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Anniversaries")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddAnniversary = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAnniversary) {
                AddAnniversaryView()
            }
        }
    }
    
    private var upcomingAnniversaries: [Anniversary] {
        anniversaries.filter { $0.daysUntil >= 0 && $0.daysUntil <= 30 }
    }
    
    private func deleteAnniversaries(offsets: IndexSet) {
        withAnimation {
            offsets.map { anniversaries[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

struct AnniversaryRow: View {
    let anniversary: Anniversary
    let showCountdown: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(anniversary.title)
                    .font(.headline)
                Spacer()
                if showCountdown {
                    CountdownBadge(anniversary: anniversary)
                }
            }
            
            Text(anniversary.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if anniversary.reminderEnabled {
                Text("Reminder: \(anniversary.reminderDaysBefore) days before")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 2)
    }
}

struct CountdownBadge: View {
    let anniversary: Anniversary
    
    var body: some View {
        Group {
            if anniversary.daysUntil > 0 {
                Text("\(anniversary.daysUntil) days")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            } else if anniversary.daysUntil == 0 {
                Text("Today!")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            } else {
                Text("D+\(anniversary.daysSince)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}