//
//  TAlarm.swift
//  ToiletApp
//
//  Created by Luca Maria Incarnato on 08/10/25.
//


import SwiftData
import SwiftUI
import Foundation
import UserNotifications
import AlarmKit
import ActivityKit

@Model
class TAlarm{
    // MARK: ATTRIBUTES
    var TID: UUID = UUID()
    var alarmIDs: [Alarm.ID] = []
    var wakeTime: Alarm.Schedule.Relative.Time = Alarm.Schedule.Relative.Time(hour: 8, minute: 30)
    var weekdays: [Locale.Weekday] = []
    var sound: String = "Princess"
    var active: Bool = false
    var created: Date = Date()
    
    // MARK: STATIC ATTRIBUTES
    static var sounds: [String] = [
        "Princess",
        "Celestial",
        "Enchanted",
        "Joy",
        "Mindful",
        "Penguin",
        "Plucks",
        "Stardust",
        "Sunday",
        "Valley"
    ]
    
    // MARK: INITIALIZERS
    init(wakeTime: Alarm.Schedule.Relative.Time) {
        self.wakeTime = wakeTime
    }
    
    init() {}
    
    // MARK: PUBLIC METHODS
    // Schedule a notification to remind of bedtime and ten alarms
    func setAlarm() async {
        active = true
        // Schedule ten alarms distanced by one minute
        for i in 0...9 {
            await scheduleAlarm(hour: wakeTime.hour, minute: wakeTime.minute + i)
        }
    }
    
    // Cancel all the alarms associated with the current alarm
    func cancelAlarm() {
        active = false
        do{
            for alarm in try AlarmManager.shared.alarms {
                // If the AlarmManager's alarm is in the current id array, cancel the alarm
                if alarmIDs.contains(alarm.id) {
                    try AlarmManager.shared.cancel(id: alarm.id)
                }
            }
        } catch {
            print("Cannot cancel alarms")
        }
    }
    
    // Get Time component and compose right string
    static func toString(_ alarm: TAlarm) -> String{
        let hourString: String
        let minuteString: String
        // If hour has only one digit add 0 in front
        if alarm.wakeTime.hour < 10 { hourString = "0\(alarm.wakeTime.hour)" }
        else { hourString = "\(alarm.wakeTime.hour)" }
        // If minute has only one digit add 0 in front
        if alarm.wakeTime.minute < 10 { minuteString = "0\(alarm.wakeTime.minute)" }
        else { minuteString = "\(alarm.wakeTime.minute)" }
        // Compose string
        return "\(hourString):\(minuteString)"
    }
    
    // MARK: PRIVATE METHODS
    // Schedule an alarm at the next hour:minute
    private func scheduleAlarm(hour: Int, minute: Int) async {
        let alarmID = UUID()
        let time = Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
        let relative = Alarm.Schedule.Relative(time: time, repeats: weekdays.isEmpty ? .never : .weekly(Array(weekdays)))
        let schedule = Alarm.Schedule.relative(relative)
        // Snooze button
        let stopButton = AlarmButton(
            text: "Snooze",
            textColor: Color.white,
            systemImageName: "battery.25percent"
        )
        // Wake up button that opens the app and starts the game
        let secondaryButton = AlarmButton(
            text: "Wake Up",
            textColor: Color.white,
            systemImageName: "basketball.fill"
        )
        // Set up the presentation for alarm
        let alertPresentation = AlarmPresentation.Alert(
            title: "Time to wake up!",
            stopButton: stopButton,
            secondaryButton: secondaryButton,
            secondaryButtonBehavior: .custom
        )
        // Get attributes for ActivityKit tools
        let attributes = AlarmAttributes<CookingData>(
            presentation: AlarmPresentation(alert: alertPresentation),
            tintColor: Color.accentColor,
        )
        // Secondary button custom action's intent
        let secondaryIntent = OpenInApp(alarmID: alarmID.uuidString)
        // Configure alarm for scheduling
        let alarmConfiguration = AlarmManager.AlarmConfiguration<CookingData>(
            schedule: schedule,
            attributes: attributes,
            secondaryIntent: secondaryIntent,
            sound: .named(sound + ".wav")
        )
        // Schedule alarm
        do {
            let _ = try await AlarmManager.shared.schedule(id: alarmID, configuration: alarmConfiguration)
            alarmIDs.append(alarmID)
        } catch {
            print("Cannot schedule alarm")
        }
    }
}

// Container for mock data 
extension TAlarm {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(for: TAlarm.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        container.mainContext.insert(TAlarm())
        return container
    }
}

nonisolated
struct CookingData: AlarmMetadata{
    // Empty implementation
}
