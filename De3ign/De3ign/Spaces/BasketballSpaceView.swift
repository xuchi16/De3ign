//
//  BasketballSpaceView.swift
//  De3ign
//
//  Created by xuchi on 2024/8/23.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct BasketballSpaceView: View {
    // Volume: 0.15, Space: 0.3
    var scale: Float = 2
    var position: SIMD3<Float> = [0, 0, -1.5]
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    private var speechSynthesizer = SpeechSynthesizer()
    @State private var isRecording = false
    @State var chatEntity = Entity()
    @State var xianglu = Entity()
    @State var xiang = Entity()
    
    init(scale: Float = 2, position: SIMD3<Float> = [0, 0, -1.5]) {
        self.scale = scale
        self.position = position
    }
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "BasketballScene", in: realityKitContentBundle) {
                immersiveContentEntity.scale = SIMD3<Float>(repeating: scale)
                immersiveContentEntity.position = position
                content.add(immersiveContentEntity)
                
                chatEntity = immersiveContentEntity.findEntity(named: "cat")!
                chatEntity.components.set(InputTargetComponent())
                chatEntity.components.set(HoverEffectComponent())
                
                if let xianglu = immersiveContentEntity.findEntity(named: "shangxiang") {
                    xianglu.components.set(InputTargetComponent())
                    xianglu.components.set(HoverEffectComponent())
                    self.xianglu = xianglu
                    
                    if let xiang = xianglu.findEntity(named: "xiang_low") {
                        self.xiang = xiang
                        xiang.isEnabled = false
                    }
                }
                
                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
        .gesture(
            TapGesture()
                .targetedToEntity(chatEntity)
                .onEnded{ ev in
                    isRecording = !isRecording
                    if isRecording {
                        print("recog start")
                        chatEntity.transform.rotation += simd_quatf(angle: 10*Float.pi/180.0, axis: SIMD3<Float>(1,0,0))
                        startRecognition()
                    } else {
                        print("recog end")
                        chatEntity.transform.rotation -= simd_quatf(angle: 10*Float.pi/180.0, axis: SIMD3<Float>(1,0,0))
                        endRecognition()
                    }
                })
        .simultaneousGesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    xiang.isEnabled.toggle()
                }
        )
    }
    
    private func startRecognition() {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
    }
    
    private func endRecognition() {
        speechRecognizer.stopTranscribing()
        isRecording = false
        print(speechRecognizer.transcript)
        doChat(message: speechRecognizer.transcript)
    }
    
    private func doChat(message: String) {
        sendChatMessage(message: message, personality: "猫") { response in
            if let response = response {
                print("response: \(response)")
                speechSynthesizer.readText(text: response)
                for anim in chatEntity.availableAnimations {
                    chatEntity.playAnimation(anim, transitionDuration: 0.2, startsPaused: false)
                }
            } else {
                print("no response")
            }
        }
    }
}

#Preview {
    BasketballSpaceView()
}
