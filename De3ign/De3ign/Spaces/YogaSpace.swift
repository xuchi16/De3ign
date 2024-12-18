//
//  ImmersiveView.swift
//  Sun
//
//  Created by xuchi on 2023/12/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

enum LightType: Float {
    case dim =  6740.94
    case regular = 26963.76
    case bright = 53927.52
}

struct YogaSpace: View {
    var scale: Float = 1
    var position: SIMD3<Float> = [0, 0, 0]
    let song = Song(name: "Jovita")
    @State var lightEntity: Entity?
    @State var isCurrentlyOn = true
    @State var particleEntity: Entity?
    @State var particleEmitting = false
    
    
    var body: some View {
        RealityView { content in
            if let immersiveContentEntity = try? await Entity(named: "YogaSpace", in: realityKitContentBundle) {
                immersiveContentEntity.scale = SIMD3<Float>(repeating: scale)
                immersiveContentEntity.position = position
                content.add(immersiveContentEntity)
                
                if let player = immersiveContentEntity.findEntity(named: "Carvaan_Music_Player") {
                    print("Player found!")
//                    player.components.set(InputTargetComponent())
                    player.components.set(HoverEffectComponent())
                    
                    if let particleEntity = player.findEntity(named: "ParticleEmitter") {
                        print("ParticleEmitter found!")
                        self.particleEntity = particleEntity
                        
                        if var particle = particleEntity.components[ParticleEmitterComponent.self] {
                            particle.isEmitting = false
                            particle.simulationState = .stop
                            particleEntity.components.set(particle)
                        }
                    }
                }
                if let lamp = immersiveContentEntity.findEntity(named: "Floor_lamp") {
                    print("Lamp found!")
                    lamp.components.set(HoverEffectComponent())
                    
                    if let lampLight = lamp.findEntity(named: "lightLamp") {
                        print("Light found!")
                        self.lightEntity = lampLight
                        
                        if var lightComponent = lampLight.components[PointLightComponent.self] {
                            // 初始化时关闭灯光
                            lightComponent.intensity = 0
                            lampLight.components.set(lightComponent)
                        }
                    }
                }
//                if let lightBilb = immersiveContentEntity.findEntity(named: "Low_Poly_Light_Bulb")
//                {
//                    if var material =  lightBilb.components[ModelComponent.self]?.materials.first as? PhysicallyBasedMaterial {
//                        material.emissiveIntensity = 0
//                        lightBilb.components[ModelComponent.self]?.materials[0] = material
//                    }
//                }

            }
        }
        .preferredSurroundingsEffect(.ultraDark)
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
//                .targetedToEntity(player)
                .onEnded { value in
                    let tappedEntity = value.entity
                    
                    if tappedEntity.name == "Carvaan_Music_Player" {
                        print("switch player")
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
                    else if tappedEntity.name == "Floor_lamp" {
                        print("switch light")
                        
                        AudioPlayer.shared.playSound(fileName: isCurrentlyOn ? "lampOff.WAV":"lampOn.WAV") {
                            print("音频播放完成")
                        }
                        
                        guard let lightEntity = self.lightEntity,
                              var ifOn = lightEntity.components[SpotLightComponent.self]
                        else {
                            print("No light")
                            return
                        }
                        
                        isCurrentlyOn.toggle()
                        print(isCurrentlyOn)
                        ifOn.intensity = isCurrentlyOn ? 7000 : 0
                        lightEntity.components[PointLightComponent.self] = ifOn
                        lightEntity.components.set(ifOn)
                        print(isCurrentlyOn ? "Light turned off" : "Light turned on")
                    }
                }
            )
    }
}
