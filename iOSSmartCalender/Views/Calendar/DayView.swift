import SwiftUI

struct DayView: View {
    let selectedDate: Date
    let events: [CalendarEvent]
    @State private var showingAddEvent = false
    let onDateSelected: (Date) -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE — MMM d, yyyy"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            // 週表示
            WeekView(selectedDate: selectedDate, onDateSelected: onDateSelected)
            // 境界線
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)
            // 日付ヘッダー
            Text(dateFormatter.string(from: selectedDate))
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            // 境界線
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)
            
            // Timeline
            ScrollViewReader { proxy in
                ScrollView {
                    ZStack(alignment: .top) {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<24) { hour in
                                TimeSlot(hour: hour, events: eventsForHour(hour))
                                    .id(hour)
                            }
                        }
                        
                        // 現在時刻の赤線
                        if calendar.isDateInToday(selectedDate) {
                            CurrentTimeLine()
                        }
                    }
                }
                .onAppear {
                    if calendar.isDateInToday(selectedDate) {
                        let currentHour = calendar.component(.hour, from: Date())
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(currentHour, anchor: .center)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddEvent) {
            AddEventView()
        }
    }
    
    private func eventsForHour(_ hour: Int) -> [CalendarEvent] {
        events.filter { event in
            Calendar.current.component(.hour, from: event.startDate) == hour
        }
    }
}

struct TimeSlot: View {
    let hour: Int
    let events: [CalendarEvent]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                // 時間ラベル
                VStack(alignment: .trailing, spacing: 8) {
                    Text(timeString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .frame(width: 50)
                .padding(.trailing, 8)
                
                // イベントエリア
                VStack(alignment: .leading, spacing: 4) {
                    if events.isEmpty {
                        Spacer()
                            .frame(height: 60)
                    } else {
                        ForEach(events, id: \.id) { event in
                            EventBlock(event: event)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
            }
            .frame(minHeight: 60)
            
            // 横線（時間区切り）
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 0.5)
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

struct EventBlock: View {
    let event: CalendarEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(event.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            if let notes = event.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue)
        .cornerRadius(4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WeekView: View {
    let selectedDate: Date
    let onDateSelected: (Date) -> Void
    private let calendar = Calendar.current
    
    private var hasSelectedDate: Bool {
        !calendar.isDateInToday(selectedDate)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { date in
                Button(action: {
                    onDateSelected(date)
                }) {
                    VStack(spacing: 4) {
                        Text(dayOfWeek(date))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor((isSelected(date) || (isToday(date) && !hasSelectedDate)) ? .white : .primary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill((isSelected(date) || (isToday(date) && !hasSelectedDate)) ? Color.red : Color.clear)
                            )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var weekDays: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }
        
        var days: [Date] = []
        var date = weekInterval.start
        
        for _ in 0..<7 {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return days
    }
    
    private func dayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    private func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
}

struct CurrentTimeLine: View {
    @State private var now = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                // 現在時刻ラベル
                Text(timeString)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.red))
                
                // 赤線
                Rectangle()
                    .fill(Color.red)
                    .frame(height: 1)
            }
            .padding(.leading, 8)
        }
        .offset(y: offsetY)
        .onReceive(timer) { _ in
            now = Date()
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: now)
    }
    
    private var offsetY: CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        
        // 1時間 = 60px として計算
        return CGFloat(hour * 60 + minute) + 60 // 最初の時間スロットの高さを加算
    }
}
