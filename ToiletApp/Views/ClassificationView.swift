//
//  ClassificationView.swift
//  ToiletApp
//
//  Created by Luca Maria Incarnato on 23/10/25.
//

import SwiftUI
import CoreML

struct ClassificationView: View {
    var body: some View {
        ZStack{
            Rectangle()
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .foregroundStyle(Color.clear)
                .border(.white)
            Text("Camera not available")
            VStack {
                Text(Date.now.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 100))
                    .bold()
                    .foregroundStyle(Color.secondary)
                Spacer()
                Button(){
                    print("CIAO")
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(Color.white)
                }
                .buttonBorderShape(.circle)
                .glassEffect(.clear.interactive(), in: Circle())
            }
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

#Preview {
    ClassificationView()
}
