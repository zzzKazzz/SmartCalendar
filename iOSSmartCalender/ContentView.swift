//
//  ContentView.swift
//  iOSSmartCalender
//
//  Created by kazuaki_tanaka_bp@mjit.co.jp on 2025/07/17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
            
            AnniversaryView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Anniversary")
                }
            
            ExpenseTrackerView()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Expenses")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
