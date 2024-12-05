//
//  Song.swift
//  De3ign
//
//  Created by xuchi on 2024/8/23.
//

import AVFoundation

struct Song {
    let name: String
    var audioPlayer: AVAudioPlayer?
    
    init(name: String) {
        self.name = name
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Music file not found")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Error playing music: \(error.localizedDescription)")
            return
        }
    }
    
    func toggle() {
        guard let audioPlayer else {
            return
        }
        if audioPlayer.isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }
}
