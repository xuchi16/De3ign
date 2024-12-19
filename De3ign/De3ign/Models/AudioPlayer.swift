
//
//  Untitled.swift
//  Yoga
//
//  Created by Jovita on 2024/12/18.
//

import Foundation
import AVFoundation

/// A utility class that manages audio playback functionality
public class AudioPlayer: NSObject {
    // MARK: - Properties
    
    /// The shared instance of AudioPlayer for singleton usage
    public static let shared = AudioPlayer()
    
    /// The current AVAudioPlayer instance
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Plays an audio file with the specified name
    /// - Parameters:
    ///   - fileName: The name of the audio file to play (including extension)
    ///   - completion: Optional closure to be called when playback completes
    public func playSound(fileName: String, completion: (() -> Void)? = nil) {
        // Get the audio file path
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            print("Error: Could not find audio file: \(fileName)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            // Initialize audio session
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Initialize audio player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            // Set completion handler if provided
            if let completion = completion {
                NotificationCenter.default.addObserver(forName: .audioPlayerDidFinishPlaying,
                                                    object: nil,
                                                    queue: .main) { _ in
                    completion()
                }
            }
            
            // Start playback
            audioPlayer?.play()
        } catch {
            print("Error playing audio file: \(error.localizedDescription)")
        }
    }
    
    /// Stops the currently playing audio
    public func stopSound() {
        audioPlayer?.stop()
    }
    
    /// Pauses the currently playing audio
    public func pauseSound() {
        audioPlayer?.pause()
    }
    
    /// Resumes playing the paused audio
    public func resumeSound() {
        audioPlayer?.play()
    }
    
    /// Checks if audio is currently playing
    /// - Returns: Boolean indicating if audio is playing
    public func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlayer: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: .audioPlayerDidFinishPlaying, object: nil)
    }
}

// MARK: - Notification Names
public extension Notification.Name {
    /// Notification posted when audio playback finishes
    static let audioPlayerDidFinishPlaying = Notification.Name("audioPlayerDidFinishPlaying")
}
