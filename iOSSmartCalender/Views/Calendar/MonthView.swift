import SwiftUI

struct MonthView: View {
    @Binding var selectedDate: Date
    @Binding var viewMode: CalendarView.ViewMode
    let events: FetchedResults<CalendarEvent>
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // 月を表示
            Text(monthString)
                .font(.system(size: 34, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.leading, 16)
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                // Weekday headers
                // TODO:なぜか木曜と土曜の頭文字だけ表示されないので本当はSとかだけにしたい
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 28)
                }
                // Calendar days
                // 今月の日付のみ表示
                ForEach(daysInMonth, id: \.self) { date in
                    if calendar.isDate(date, equalTo: selectedDate, toGranularity: .month) {
                        DayCell(date: date, 
                               isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                               hasEvents: hasEvents(for: date),
                               onTap: { 
                                   selectedDate = date
                                   viewMode = .timeline
                               })
                        .frame(maxWidth: .infinity, minHeight: calcCellHeight)
                    } else {
                        Color.clear
                            .frame(maxWidth: .infinity, minHeight: calcCellHeight)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1)
        else { return [] }
        
        var dates: [Date] = []
        var date = monthFirstWeek.start
        
        while date < monthLastWeek.end {
            dates.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return dates
    }
    
    private func hasEvents(for date: Date) -> Bool {
        events.contains { event in
            calendar.isDate(event.startDate, inSameDayAs: date)
        }
    }
    // 前の月表示用
    private func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }
    // 次の月表示用
    private func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
    }
    // 月表示用
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: selectedDate)
    }

    // 1セルの高さを自動計算（6行分で分割）
    private var calcCellHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        // 上部のタイトルやヘッダー分を差し引いて6分割
        let header: CGFloat = 90 // タイトルや曜日ヘッダーの高さ
        let tabBar: CGFloat = 80 // 下部タブバーの高さ
        return (screenHeight - header - tabBar) / 6
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasEvents: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(dayTextColor)
                
                if hasEvents {
                    Circle()
                        .fill(isSelected ? Color.white : Color.blue)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(isSelected ? Color.blue : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 曜日ごとに色分け
    private var dayTextColor: Color {
        if isSelected {
            return .white
        }
        let weekday = calendar.component(.weekday, from: date)
        if weekday == 1 || weekday == 7 {
            return .secondary // 土日: 薄グレー
        } else {
            return .primary // 平日: 黒
        }
    }
}