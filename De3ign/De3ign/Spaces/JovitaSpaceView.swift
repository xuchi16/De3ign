//
//  JovitaSpaceView.swift
//  De3ign
//
//  Created by xuchi on 2024/8/22.
//

import SwiftUI
import RealityKit
import RealityKitContent
import AVKit

struct JovitaSpaceView: View {
    
    var scale: Float = 0.3
    var videoPlayer_scale: Float = 0.01
    var position: SIMD3<Float> = [0, -1, -1.5]
    let song = Song(name: "Jovita")
    @State var particleEntity: Entity?
    @State var particleEmitting = false
    @State private var windowPosition = CGPoint(x: 100, y: 100)
    @State private var isDragging = false
    @State private var showVideoWindow = false
    @State var entity = Entity()
    var playModel: PlayModel
    
    
    var body: some View {
        RealityView { content, attachments in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "JovitaScene", in: realityKitContentBundle) {
                immersiveContentEntity.scale = SIMD3<Float>(repeating: scale)
                immersiveContentEntity.position = position
                content.add(immersiveContentEntity)
                
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
                    
                let tv = try! await Entity(named: "tv_retro", in: realityKitContentBundle)
                    print("videoPlayer found!")
                    tv.position = SIMD3<Float>(x: -0.2, y: 1, z: -0.5)
                    tv.scale = SIMD3<Float>(repeating: videoPlayer_scale)
                    if let screen = tv.findEntity(named: "tv_retro_2_RetroTVScreen") as? ModelEntity {
                        let player = playModel.player
                        let material = VideoMaterial(avPlayer: player)
                        screen.model?.materials = [material]
                        player.play()
                }
                    
                entity.addChild(tv)
                if let attachment = attachments.entity(for: "controller") {
                    attachment.position = [-0.2, 0.98, -0.4]
                    entity.addChild(attachment)
                }
                    
                immersiveContentEntity.addChild(entity)
            }
        } attachments: {
            Attachment(id: "controller") {
                ControllerView(playModel: playModel)
            }
        }
        .onAppear() {
            if let url = Bundle.main.url(forResource: "video", withExtension: "mp4") {
                playModel.load(url)
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    song.toggle()
                    
                    guard let particleEntity = self.particleEntity,
                          var particle = particleEntity.components[ParticleEmitterComponent.self] else {
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
#Preview {
    JovitaSpaceView(playModel: PlayModel())
        .previewLayout(.sizeThatFits)
}
