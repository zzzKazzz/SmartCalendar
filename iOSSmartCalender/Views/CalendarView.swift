import SwiftUI
import CoreData

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CalendarEvent.startDate, ascending: true)],
        animation: .default)
    private var events: FetchedResults<CalendarEvent>
    
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    @State private var viewMode: ViewMode = .month
    // 今あるモード
    enum ViewMode {
        case month, timeline
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 共通ヘッダー
                HStack {
                    // 月表示の場合は月＋年表示
                    if viewMode == .month {
                        Text(yearString)
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundColor(.primary)
                    // 月以外の場合は戻るボタン＋月表示
                    } else {
                        Button(action: { viewMode = .month }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .medium))
                            Text(monthString)
                                .font(.headline)
                                .fontWeight(.regular)
                                .foregroundColor(.red)
                        }
                        .foregroundColor(.red)
                    }
                    Spacer()
                    // plusボタンは常に表示
                    Button(action: { showingAddEvent = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                if viewMode == .month {
                    MonthView(selectedDate: $selectedDate, viewMode: $viewMode, events: events)
                } else {
                    DayView(selectedDate: selectedDate, events: eventsForSelectedDate) { newDate in
                        selectedDate = newDate
                    }
                }
                
                Spacer()
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView()
            }
        }
    }
    
    private var eventsForSelectedDate: [CalendarEvent] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: selectedDate)
        }
    }
    // 月表示用
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: selectedDate)
    }
    // 年表示用
     private var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: selectedDate)
    }
}
