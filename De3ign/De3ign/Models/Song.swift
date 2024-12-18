//
//  Song.swift
//  De3ign
//
//  Created by xuchi on 2024/8/23.
//

import AVFoundation

struct Song {
    let name: String
    var audioPlayer: AVAudioPlayer
    
    init(name: String) {
        self.name = name
        let url = Bundle.main.url(forResource: name, withExtension: "mp3")!
        audioPlayer = try! AVAudioPlayer(contentsOf: url)
    }
    
    func toggle() {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }
    
    @discardableResult
    func volume(_ value: Float) -> Song {
        audioPlayer.volume = value
        return self
    }
    
    @discardableResult
    func loop() -> Song {
        audioPlayer.numberOfLoops = -1
        return self
    }
    
    @discardableResult
    func play() -> Song {
        audioPlayer.play()
        return self
    }
    
    func stop() {
        audioPlayer.stop()
    }
}
