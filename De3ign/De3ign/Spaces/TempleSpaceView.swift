//
//  TempleSpaceView.swift
//  De3ign
//
//  Created by xuchi on 2024/8/23.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct TempleSpaceView: View {
    var scale: Float
    var position: SIMD3<Float>
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    private var speechSynthesizer = SpeechSynthesizer()
    @State private var isRecording = false
    
    private var rootEntity = Entity()
    @State var chatEntity = Entity()
    
    init(scale: Float = 0.01, position: SIMD3<Float> = [0, -1, -1.5]) {
        self.scale = scale
        self.position = position
    }
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                rootEntity.addChild(immersiveContentEntity)
                
                chatEntity = immersiveContentEntity.findEntity(named: "cat")!
                //chatEntity.position = [-5.2569, 2.53341, -12.18514]
                
                //chatEntity.generateCollisionShapes(recursive: true)
                chatEntity.components.set(InputTargetComponent())
                chatEntity.components.set(HoverEffectComponent())
                rootEntity.addChild(chatEntity)
                
                guard let resource = try? await TextureResource(named: "marskybox") else {
                    // If the asset isn't available, something is wrong with the app.
                    fatalError("Unable to load texture.")
                }
                var material = UnlitMaterial()
                material.color = .init(texture: .init(resource))
                // Attach the material to a large sphere.
                let skybox = Entity()
                skybox.components.set(ModelComponent(
                    mesh: .generateSphere(radius: 1000),
                    materials: [material]
                ))
                // Ensure the texture image points inward at the viewer.
                skybox.scale *= .init(x: -1, y: 1, z: 1)
                content.add(skybox)
                
                content.add(rootEntity)
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
        sendChatMessage(message: message) { response in
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
    TempleSpaceView()
}
