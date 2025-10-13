//
//  WeeklyRepetitionView.swift
//  ToiletApp
//
//  Created by Luca Maria Incarnato on 13/10/25.
//


import SwiftUI
import Foundation

struct WeeklyRepetitionView: View {
    // MARK: ATTRIBUTES
    @Binding var alarm: TAlarm
    var day: String = "M"
    var weekvalue: Locale.Weekday = .monday
    var isSelected: Bool {
        alarm.weekdays.contains(weekvalue)
    }
    let weekvalues: [Locale.Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    // MARK: VIEW BODY
    var body: some View {
        Button(){
            // If selected and the weekday is not in the alarm, add it, if not selected and it is contained, remove it
            if isSelected {
                alarm.weekdays.removeAll(where: { $0 == weekvalue })
            } else {
                alarm.weekdays.append(weekvalue)
            }
            // Sort the week
            alarm.weekdays.sort { weekvalues.firstIndex(of: $0)! < weekvalues.firstIndex(of: $1)! }
        } label: {
            ZStack{
                Circle()
                    .foregroundStyle(isSelected ? Color.accentColor : Color.clear)
                    .frame(width: 40)
                Text(day)
                    .foregroundStyle(isSelected ? Color.black : Color.white)
                    .font(.title3)
                    .bold(isSelected)
            }
        }
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: Circle())
        .sensoryFeedback(.selection, trigger: isSelected)
        .id(weekvalue)
    }
}
