//
//  ToilarmApp.swift
//  Toilarm
//
//  Created by Luca Maria Incarnato on 08/10/25.
//

import SwiftUI
import SwiftData

@main
struct ToilarmApp: App {
    var body: some Scene {
        WindowGroup {
            AlarmListView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: TAlarm.self, isAutosaveEnabled: false)
    }
}
