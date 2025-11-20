//
//  OnboardingView.swift
//  Toilarm
//
//  Created by Luca Maria Incarnato on 20/11/25.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("Onboarding") var onboarding: Bool = true

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 40)
            Text("Welcome to\nToilarm")
                .font(.system(size: 38, weight: .heavy))
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 30) {
                FeatureRow(
                    iconName: "envelope",
                    title: "Found Events",
                    description: "Siri suggests events found in Mail, Messages, and Safari, so you can add them easily, such as flight reservations and hotel bookings."
                )
                
                FeatureRow(
                    iconName: "clock",
                    title: "Time to Leave",
                    description: "Calendar uses Apple Maps to look up locations, traffic conditions, and transit options to tell you when it's time to leave."
                )
                
                FeatureRow(
                    iconName: "location",
                    title: "Location Suggestions",
                    description: "Calendar suggests locations based on your past events and significant locations."
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button() {
                onboarding = false
                let alarm = TAlarm()
                alarm.created = Date.now.addingTimeInterval(-500)
                modelContext.insert(alarm)
            } label: {
                Text("Continue")
                    .font(.title3)
                    .bold()
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}

struct FeatureRow: View {
    var iconName: String
    var title: String
    var description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 36))
                .foregroundColor(Color.accent)
                .frame(width: 40, alignment: .center)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.callout)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
