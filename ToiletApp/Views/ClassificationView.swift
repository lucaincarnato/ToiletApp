//
//  ClassificationView.swift
//  ToiletApp
//
//  Created by Luca Maria Incarnato on 23/10/25.
//

import SwiftUI
import CoreML

struct ClassificationView: View {
    @State var image: UIImage?
    @State var show: Bool = false
    @State var prediction: String = "No prediction yet"
    
    var body: some View {
        VStack{
            Button(prediction) {
                show = true
            }
        }
        .fullScreenCover(isPresented: $show, onDismiss: {
            Task {
                prediction = await classify((image?.toCVPixelBuffer())!) ?? "No prediction yet"
            }
        }){
            CameraView(image: $image)
                .ignoresSafeArea()
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
