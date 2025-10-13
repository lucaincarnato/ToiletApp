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
                if alarms.isEmpty {
                    Text("No alarms")
                        .font(.subheadline)
                        .padding()
                        .foregroundStyle(.gray)
                } else {
                    List {
                        ForEach(alarms, id: \.self) { alarm in
                            AlarmCard(alarm: alarm)
                        }
                        .onDelete(perform: deleteAlarm)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button() {
                        let newAlarm = TAlarm(
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
            }
        }
    }
    
    // MARK: PRIVATE METHODS
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
    
    // Safely deletes an item when swiped from list
    private func deleteAlarm(at offsets: IndexSet) {
        for index in offsets {
            let alarm = alarms[index]
            modelContext.delete(alarm)
        }
        try? modelContext.save()
    }
}

#Preview {
    AlarmListView()
        .modelContainer(TAlarm.preview)
}
