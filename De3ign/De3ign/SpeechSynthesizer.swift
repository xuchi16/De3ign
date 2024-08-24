//
//  SpeechSynthesizer.swift
//  test2
//
//  Created by Michael on 2024/8/23.
//

import AVFoundation

struct SpeechSynthesizer {
    private var synthesizer = AVSpeechSynthesizer()
    
    func readText(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        print(AVSpeechSynthesisVoice.speechVoices())
        utterance.voice = AVSpeechSynthesisVoice(language: "zh_Hans")
        
        synthesizer.speak(utterance)
    }
}
