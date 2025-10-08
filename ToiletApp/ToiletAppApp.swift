//
//  ToiletAppApp.swift
//  ToiletApp
//
//  Created by Luca Maria Incarnato on 08/10/25.
//

import SwiftUI
import SwiftData

@main
struct ToiletAppApp: App {
    var body: some Scene {
        WindowGroup {
            AlarmListView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: TAlarm.self, isAutosaveEnabled: false)
    }
}
