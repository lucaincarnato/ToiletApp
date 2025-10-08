//
//  AudioPlayer.swift
//  ToiletApp
//
//  Created by Luca Maria Incarnato on 08/10/25.
//

import Combine
import Foundation
import AVFoundation

class AudioPlayer: ObservableObject {
    private var player: AVAudioPlayer?
    
    func playSound(_ fileName: String, loop: Bool = false) {
        if let player = player, player.isPlaying {
            return
        }
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else {
            print("File not found")
            return
        }
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            if loop {
                player?.numberOfLoops = -1
            }
            player?.volume = 1.0
            player?.play()
        } catch {
            print("Error while playing audio file: \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        if let player = player {
            player.stop()
            player.currentTime = 0
        } else {
            print("No audio to stop")
        }
    }
}
