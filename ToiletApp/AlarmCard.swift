//
//  AlarmCard.swift
//  ToiletApp
//
//  Created by Luca Maria Incarnato on 08/10/25.
//

import SwiftUI
import SwiftData

struct AlarmCard: View {
    // MARK: ATTRIBUTES
    @Environment(\.modelContext) private var modelContext
    @State var alarm: TAlarm
    @AppStorage("ToiletRecognition") private var alarmGame: Bool = false
    
    // MARK: VIEW BODY
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(TAlarm.toString(alarm))
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(alarm.active ? Color.white : Color.secondary)
                if !alarm.weekdays.isEmpty {
                    HStack{
                        ForEach(alarm.weekdays, id: \.self) { day in
                            Text(day.rawValue)
                                .font(.caption)
                                .foregroundStyle(alarm.active ? Color.white : Color.secondary)
                        }
                    }
                } else {
                    Text("No repeating")
                        .foregroundStyle(alarm.active ? Color.white : Color.secondary)
                }
            }
            Spacer()
            Toggle("", isOn: $alarm.active)
                .toggleStyle(SwitchToggleStyle())
                .onChange(of: alarm.active){ oldValue, newValue in
                    if !newValue {
                        alarm.cancelAlarm()
                    } else {
                        Task{ await alarm.setAlarm() }
                    }
                    try? modelContext.save()
                }
        }
        .fullScreenCover(isPresented: $alarmGame) {
            Text("NO WAY YOU WOKE UP")
        }
    }
}
