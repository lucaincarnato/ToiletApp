//
//  AlarmListView.swift
//  ToiletApp
//
//  Created by Luca Maria Incarnato on 08/10/25.
//

import SwiftUI
import AlarmKit
import SwiftData

struct AlarmListView: View {
    // MARK: ATTRIBUTES
    @Query(sort: \TAlarm.wakeTime.hour, order: .forward) private var alarms: [TAlarm]
    @Environment(\.modelContext) private var modelContext
    @AppStorage("Onboarding") var onboarding: Bool = true
    
    // MARK: VIEW BODY
    var body: some View {
        NavigationStack {
            VStack {
                /*
                 CARDS FOR THE ALARMS
                 */
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button() {
                        let newAlarm = TAlarm(
                            sleepTime: Alarm.Schedule.Relative.Time(hour: 0, minute: 0),
                            wakeTime: Alarm.Schedule.Relative.Time(hour: 8, minute: 0)
                        )
                        modelContext.insert(newAlarm)
                        try? modelContext.save()
                    } label: {
                        Label("", systemImage: "plus")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .task {
                // Asks for permission before even starting the app
                let _ = await requestAlarmPermission()
                requestNotificationPermission()
            }
        }
    }
    
    // MARK: PRIVATE METHODS
    // Asks for notification permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error while asking permission: \(error.localizedDescription)")
            }
        }
    }
    
    // Asks for alarm permission
    private func requestAlarmPermission() async -> Bool {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            do {
                return try await AlarmManager.shared.requestAuthorization() == .authorized
            } catch {
                return false
            }
        case .authorized:
            return true
        case .denied:
            return true
            
        @unknown default:
            return false
        }
    }
}

#Preview {
    AlarmListView()
}
