//
//  SetAlarmView.swift
//  Toilarm
//
//  Created by Luca Maria Incarnato on 10/10/25.
//

import SwiftUI
import AVFAudio
import SwiftData
import AlarmKit

struct SetAlarmView: View {
    // MARK: ATTRIBUTES
    @Environment(\.modelContext) private var modelContext
    @Binding var alarm: TAlarm
    @State private var time = Date()
    @Binding var setAlarm: Bool
    @State private var audioPlayer: AVAudioPlayer?
    @State private var success: Bool = false
    let weekdays: [String] = ["M", "T", "W", "T", "F", "S", "S"]
    let weekvalues: [Locale.Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    // MARK: VIEW BODY
    var body: some View {
        NavigationStack{
            VStack{
                Form{
                    // MARK: Time Picker
                    DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .onChange(of: time) { oldDate, newDate in
                            let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                            let hour = components.hour ?? 0
                            let minute = components.minute ?? 0
                            alarm.wakeTime = Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
                        }
                        .onAppear {
                            let now = Date()
                            let today = Calendar.current.startOfDay(for: now)
                            let wakeTime = alarm.wakeTime
                            // Conversione: setta il tempo iniziale usando l'ora e il minuto di wakeTime
                            time = Calendar.current.date(bySettingHour: wakeTime.hour, minute: wakeTime.minute, second: 0, of: today) ?? now
                        }
                    // MARK: Alarm Options
                    Section {
                        HStack (alignment: .center){
                            ForEach(weekdays.indices, id: \.self) {i in
                                WeeklyRepetitionView(alarm: $alarm, day: weekdays[i], weekvalue: weekvalues[i])
                            }
                        }
                        Picker("Alarm sound", selection: makeBinding(String.self)) {
                            ForEach(TAlarm.sounds, id:\.self) {
                                Text($0.description)
                                    .tag($0)
                            }
                        }
                    }
                    // MARK: Delete Button
                    Button(role: .destructive){
                        alarm.cancelAlarm()
                        modelContext.delete(alarm)
                        try? modelContext.save()
                        setAlarm.toggle()
                    } label: {
                        Text("Delete")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Set Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .sensoryFeedback(.success, trigger: success == true)
            .toolbar{
                ToolbarItem(placement: .cancellationAction, ){
                    Button(role: .cancel){
                        stopAudio()
                        setAlarm.toggle()
                        modelContext.rollback()
                        // Changes the modelContext to allow view refresh
                        modelContext.insert(alarm)
                        modelContext.delete(alarm)
                    }
                }
                ToolbarItem(placement: .confirmationAction){
                    Button(role: .confirm){
                        success = true
                        stopAudio()
                        try? modelContext.save()
                        Task { await alarm.setAlarm() }
                        setAlarm.toggle()
                    }
                }
            }
        }
    }
    
    // MARK: PRIVATE METHODS
    // Stop any sound and plays the one selected
    private func playAudio(for track: String?) {
        guard let track = track else { return }
        stopAudio()
        let trackURL = Bundle.main.url(forResource: track, withExtension: "wav")
        do {
            if let url = trackURL {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            }
        } catch {
            print("Errore nella riproduzione audio: \(error)")
        }
    }
    
    // Stop audio playing
    private func stopAudio(){
        audioPlayer?.stop()
    }
    
    // Bind the audio's name to play sound as soon as it is selected
    private func makeBinding(_ type: String.Type) -> Binding<String> {
        Binding(
            get: { alarm.sound },
            set: { newValue in
                alarm.sound = newValue
                playAudio(for: newValue)
            }
        )
    }
    
    private func makeBinding(_ type: Locale.Weekday.Type) -> Binding<Locale.Weekday> {
        Binding(
            get: { .sunday },
            set: { newValue in
                if !alarm.weekdays.contains(newValue) {
                    alarm.weekdays.append(newValue)
                }
            }
        )
    }
}
