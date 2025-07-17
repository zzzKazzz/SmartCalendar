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
    
    enum ViewMode {
        case month, day
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // View Mode Picker
                Picker("View Mode", selection: $viewMode) {
                    Text("Month").tag(ViewMode.month)
                    Text("Day").tag(ViewMode.day)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if viewMode == .month {
                    MonthView(selectedDate: $selectedDate, events: events)
                } else {
                    DayView(selectedDate: selectedDate, events: eventsForSelectedDate)
                }
                
                Spacer()
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEvent = true }) {
                        Image(systemName: "plus")
                    }
                }
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
}