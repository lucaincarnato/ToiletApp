//
//  AlarmCard.swift
//  ToiletApp
//
//  Created by Luca Maria Incarnato on 08/10/25.
//

import SwiftUI
import SwiftData
import CoreML

struct AlarmCard: View {
    // MARK: ATTRIBUTES
    @Environment(\.modelContext) private var modelContext
    @State var alarm: TAlarm
    @State var setAlarm: Bool = false
    @State var image: UIImage?
    @State var prediction: String = "No prediction yet"
    @AppStorage("ToiletRecognition") private var alarmGame: Bool = false
    
    // MARK: VIEW BODY
    var body: some View {
        Button() {
            setAlarm.toggle()
        } label: {
            HStack{
                VStack(alignment: .leading){
                    Text(TAlarm.toString(alarm))
                        .font(.system(size: 60, weight: .light))
                        .foregroundStyle(alarm.active ? Color.white : Color.secondary)
                    if !alarm.weekdays.isEmpty {
                        HStack{
                            ForEach(alarm.weekdays, id: \.self) { day in
                                Text(day.rawValue.uppercased())
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
        }
        .fullScreenCover(isPresented: $alarmGame, onDismiss: {
            Task {
                prediction = await classify((image?.toCVPixelBuffer())!) ?? "No prediction yet"
            }
        }){
            CameraView(image: $image)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $setAlarm) {
            SetAlarmView(alarm: $alarm, setAlarm: $setAlarm)
        }
        .onAppear {
            setAlarm = Date.now.timeIntervalSince(alarm.created) < 0.5
        }
    }
    
    func classify(_ image: CVPixelBuffer) async -> String? {
        do {
            let config = MLModelConfiguration()
            let model = try COBClassifier(configuration: config)
            let prediction = try model.prediction(image: image)
            return prediction.targetProbability.sorted(by: { $0.value > $1.value }).first?.key
        } catch {
            print("Error classifying image: \(error)")
            return nil
        }
    }
}

extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let width = Int(size.width)
        let height = Int(size.height)
        
        // Crea il Pixel Buffer
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32ARGB,
                                         attributes,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        // Crea un contesto CoreGraphics per disegnare l'immagine
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            CVPixelBufferUnlockBaseAddress(buffer, [])
            return nil
        }

        UIGraphicsPushContext(context)
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        UIGraphicsGetCurrentContext()?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}
