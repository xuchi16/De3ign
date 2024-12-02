//
//  Chatter.swift
//  De3ign
//
//  Created by Lemocuber on 2024/11/17.
//

struct Chatter {
    private var speechRecognizer = SpeechRecognizer()
    private var speechSynthesizer = SpeechSynthesizer()
    var isRecording = false
    var personality: String = ""
    private var callback: (() -> Void)?
    
    @MainActor mutating func toggle() {
        if !self.isRecording {
            startRecognition()
        } else {
            endRecognition()
        }
    }
    
    @MainActor mutating func startRecognition() {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        self.isRecording = true
    }
    
    @MainActor mutating func endRecognition() {
        speechRecognizer.stopTranscribing()
        isRecording = false
        print(speechRecognizer.transcript)
        doChat(message: speechRecognizer.transcript)
    }
    
    private func doChat(message: String) {
        sendChatMessage(message: message, personality: self.personality) { response in
            if let response = response {
                print("response: \(response)")
                self.callback?()
                speechSynthesizer.readText(text: response)
            } else {
                print("no response")
            }
        }
    }
}
