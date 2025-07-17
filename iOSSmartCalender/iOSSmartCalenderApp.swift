//
//  iOSSmartCalenderApp.swift
//  iOSSmartCalender
//
//  Created by kazuaki_tanaka_bp@mjit.co.jp on 2025/07/17.
//

import SwiftUI

@main
struct iOSSmartCalenderApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
