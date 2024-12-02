//
//  JovitaSpaceView.swift
//  De3ign
//
//  Created by xuchi on 2024/8/22.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct JovitaSpaceView: View {
    // Camera
    @Environment(CaptureModel.self) var captureModel
    
    // Volume: 0.15, Space: 0.3
    var scale: Float = 0.3
    var position: SIMD3<Float> = [0, -1, -1.5]
    let song = Song(name: "Jovita")
    @State var particleEntity: Entity?
    @State var particleEmitting = false
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "JovitaScene", in: realityKitContentBundle) {
                immersiveContentEntity.scale = SIMD3<Float>(repeating: scale)
                immersiveContentEntity.position = position
                content.add(immersiveContentEntity)
                
                // 渲染到录屏中
                captureModel.mrcManager.referenceEntity = immersiveContentEntity
                
                if let player = immersiveContentEntity.findEntity(named: "Carvaan_Music_Player") {
                    print("Player found!")
                    player.components.set(HoverEffectComponent())
                    
                    if let particleEntity = player.findEntity(named: "ParticleEmitter") {
                        self.particleEntity = particleEntity
                        
                        if var particle = particleEntity.components[ParticleEmitterComponent.self] {
                            particle.isEmitting = false
                            particle.simulationState = .stop
                            particleEntity.components.set(particle)
                        }
                    }
                }
                
                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { _ in
                    song.toggle()
                    
                    guard let particleEntity = self.particleEntity,
                          var particle = particleEntity.components[ParticleEmitterComponent.self]
                    else {
                        print("No particle")
                        return
                    }
                    
                    particleEmitting.toggle()
                    particle.isEmitting = particleEmitting
                    particle.simulationState = particleEmitting ? .play : .stop
                    particleEntity.components.set(particle)
                }
        )
    }
}
