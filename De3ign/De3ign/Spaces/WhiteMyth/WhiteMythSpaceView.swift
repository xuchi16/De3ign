//
//  WhiteMythSpaceView.swift
//  De3ign
//
//  Created by Lemocuber on 2024/12/5.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct WhiteMythSpaceView: View {
    var scale: Float = 1
    var position: SIMD3<Float> = [0, 0, 0]

    init(scale: Float?, position: SIMD3<Float>?) {
        self.scale = scale ?? self.scale
        self.position = position ?? self.position
        
        PositionGuardSystem.registerSystem()
    }
    
    func outOfBoundChecker(pos: SIMD3<Float>) -> Bool {
        if
            pos.y < -2 ||
            abs(pos.x) > 12.5 ||
            abs(pos.z) > 12.5 ||
            pos.y > 21
        {
            return true
        }
        return false
    }
    
    @State var backgroundMusic: Song? = nil
    let PASSWORD = "371653"

    @State var safeEntity = Entity()
    @State var safeAttachment = Entity()

    @State var isWindowOpen = false
    @State var isLightOn = true
    @State var isCandleLit = false
    @State var safeKeypadInput: String = ""
    
    var body: some View {
        RealityView { content, attachments in
            let sceneEntity = try! await Entity(named: "WhiteMyth", in: realityKitContentBundle)
            sceneEntity.scale = SIMD3<Float>(repeating: scale)
            sceneEntity.position = position
            content.add(sceneEntity)
            
            // grant hover effects
            let hoverableEntities = sceneEntity.findAllChildrenWithComponent(
                HasHoverEffectComponent.self, excludingDescendants: true
            )
            for entity in hoverableEntities {
                entity.components.set(HoverEffectComponent())
            }

            // grab entities
            let windowEntity = sceneEntity.findChildAndSetMetadata(named: "window_animated")
            let windowSwitchEntity = sceneEntity.findChildAndSetMetadata(named: "switch_window")
            let lightSwitchEntity = sceneEntity.findChildAndSetMetadata(named: "switch_light")
            let lightSourceEntity = sceneEntity.findChildAndSetMetadata(named: "ceilinglight")
            let lighterEntity = sceneEntity.findChildAndSetMetadata(named: "lighter")
            let candleEntity = sceneEntity.findChildAndSetMetadata(named: "candle")
            let candleFireEntity = sceneEntity.findChildAndSetMetadata(named: "candlefire")
            let paperEntity = sceneEntity.findChildAndSetMetadata(named: "paper")
            let dresserEntity = sceneEntity.findChildAndSetMetadata(named: "dresser")
            let dresserLockEntity = sceneEntity.findChildAndSetMetadata(named: "dresserlock")
            let hammerEntity = sceneEntity.findChildAndSetMetadata(named: "hammer")
            let breakableFloorEntity = sceneEntity.findChildAndSetMetadata(named: "breakablefloor")
            let dresserKeyEntity = sceneEntity.findChildAndSetMetadata(named: "dresserkey")
            let batteryEntity = sceneEntity.findChildAndSetMetadata(named: "battery")
            let snowGlobeEntity = sceneEntity.findChildAndSetMetadata(named: "snowglobe")
            let ceilingEntity = sceneEntity.findChildAndSetMetadata(named: "ceiling")
            let ceilingSnowEntity = sceneEntity.findChildAndSetMetadata(named: "ceiling_snow")
            let photoFrameEntity = sceneEntity.findChildAndSetMetadata(named: "photoframe")
            let photoFrameAltImageEntity = sceneEntity.findChildAndSetMetadata(named: "secondphoto")
            safeEntity = sceneEntity.findChildAndSetMetadata(named: "safe_animated")
            let doorkeyEntity = sceneEntity.findChildAndSetMetadata(named: "doorkey")
            let doorLockAnchorEntity = sceneEntity.findChildAndSetMetadata(named: "anchor_doorlock")
            let doorEntity = sceneEntity.findChildAndSetMetadata(named: "door_animated")
            
            // place attachment
            safeAttachment = attachments.entity(for: "safe_keypad")!
            safeEntity.addChild(safeAttachment)
            safeAttachment.scale *= 2
            safeAttachment.setPosition([
                safeEntity.visualBounds(relativeTo: safeEntity).max.x + 0.001,
                safeEntity.visualBounds(relativeTo: safeEntity).max.y - 0.52,
                0,
            ], relativeTo: safeEntity)
            safeAttachment.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
            
            /*
             * store materials
             */
            let paperHiddenMaterial = paperEntity.firstModelEntity()!.model!.materials
            
            /*
             * default states
             */
            
            windowEntity.playAnimationWithName("close")
            windowSwitchEntity.playAnimationWithName("off")
            lightSwitchEntity.playAnimationWithName("on")
            
            candleFireEntity.isEnabled = false
            
            paperEntity.firstModelEntity()!.model!.materials = [
                SimpleMaterial(color: .white, isMetallic: false), // hide message with blank material
            ]
            
            snowGlobeEntity.findParticleEmittingEntity()!.isEnabled = false
            
            photoFrameAltImageEntity.isEnabled = false
            
            ceilingSnowEntity.isEnabled = false
            
            safeAttachment.isEnabled = false
            
            /*
             * interaction logic
             */
            windowEntity.whenTapped {
                windowEntity.toggleAllAnimations()
            }
            
            windowSwitchEntity.whenTapped {
                windowSwitchEntity.playAllAudios()
                self.isWindowOpen.toggle()
                windowEntity.playAudioWithName("turn", volume: -10)
                if isWindowOpen {
                    windowSwitchEntity.playAnimationWithName("on", speed: 100)
                    windowEntity.playAnimationWithName("open", speed: 2)
                } else {
                    windowSwitchEntity.playAnimationWithName("off", speed: 100)
                    windowEntity.playAnimationWithName("close", speed: 2)
                }
            }
            
            lightSwitchEntity.whenTapped {
                lightSwitchEntity.playAllAudios()
                self.isLightOn.toggle()
                if isLightOn {
                    lightSwitchEntity.playAnimationWithName("on", speed: 100)
                    lightSourceEntity.isEnabled = true
                } else {
                    lightSwitchEntity.playAnimationWithName("off", speed: 100)
                    lightSourceEntity.isEnabled = false
                }
            }
            
            lighterEntity.draggable(outOfBoundChecker)
                .whenDistance(to: candleFireEntity, within: 0.2) {
                    print("on fire!")
                    Task {
                        lighterEntity.playAllAudios()
                        candleFireEntity.particleBurst()
                        try! await Task.sleep(nanoseconds: 0_600_000_000)
                        lighterEntity.isEnabled = false
                        candleFireEntity.isEnabled = true
                        candleFireEntity.playAllAudios(loop: true)
                    }
                    isCandleLit = true
                }
            
            paperEntity.draggable(outOfBoundChecker)
                .whenDistance(to: candleFireEntity, within: 0.2, always: true) {
                    if !isCandleLit {
                        print("candle unlit")
                        return
                    }
                    paperEntity.firstModelEntity()!.model!.materials = paperHiddenMaterial
                    print("paper says 16")
                    paperEntity.components.remove(InteractOnDistanceComponent.self)
                }
            
            dresserKeyEntity.draggable(outOfBoundChecker)
                .whenDistance(to: dresserLockEntity, within: 0.4) {
                    Task {
                        dresserKeyEntity.components.remove(DragToMoveComponent.self)
                        await dresserKeyEntity.magneticMove(to: dresserLockEntity, duration: 2)
                        dresserLockEntity.playAllAudios()
                        dresserKeyEntity.isEnabled = false
                        dresserEntity.playAllAnimations()
                        try! await Task.sleep(nanoseconds: 1_300_000_000)
                        dresserEntity.pauseAllAnimations()
                        dresserEntity.unfocus()
                    }
                }
            
            // hidden COCKROOOOOOAAACH
            let cockroachEntity = sceneEntity.findChildAndSetMetadata(named: "cockroach")
            let iphoneEntity = sceneEntity.findChildAndSetMetadata(named: "iphone")
            iphoneEntity.draggable().whenDistance(to: cockroachEntity, within: 0.3) {
                cockroachEntity.playAllAnimations(loop: true)
                Task {
                    while true {
                        cockroachEntity.transform.rotation *= simd_quatf(angle: 0.03, axis: [0, 1, 0])
                        try! await Task.sleep(nanoseconds: 0_050_000_000)
                    }
                }
            }
            
            batteryEntity.draggable().whenDistance(to: snowGlobeEntity, within: 0.3) {
                Task {
                    batteryEntity.components.remove(DragToMoveComponent.self)
                    await batteryEntity.magneticMove(to: snowGlobeEntity, duration: 3)
                    batteryEntity.isEnabled = false
                    snowGlobeEntity.findParticleEmittingEntity()!.isEnabled = true
                    ceilingEntity.isEnabled = false
                    ceilingSnowEntity.isEnabled = true
                    
                    backgroundMusic?.stop()
                    backgroundMusic = Song(name: "whitemyth_alt").volume(0.4).loop().play()
                    photoFrameAltImageEntity.isEnabled = true
                }
            }
            
            hammerEntity.draggable(outOfBoundChecker)
                .whenCollided(with: breakableFloorEntity, content: content, withSoundEffect: "thump") {
                    print("break")
                    Task {
                        breakableFloorEntity.playAudioWithName("crack")
                        try! await Task.sleep(nanoseconds: 0_500_000_000)
                        breakableFloorEntity.isEnabled = false
                        hammerEntity.isEnabled = false
                    }
                }
            
            safeEntity.whenTapped {
                safeAttachment.isEnabled = true
            }
            
            doorkeyEntity.draggable().whenDistance(to: doorLockAnchorEntity, within: 0.3) {
                doorkeyEntity.isEnabled = false
                doorLockAnchorEntity.playAllAudios()
                doorEntity.playAnimationWithName("open")
                print("escape success!")
            }
            
        } attachments: {
            Attachment(id: "safe_keypad") {
                SafeKeypadView(
                    input: $safeKeypadInput,
                    maxLength: 6,
                    verify: { _ in
                        if safeKeypadInput == PASSWORD {
                            safeAttachment.isEnabled = false
                            safeEntity.playAudioWithName("open", speed: 0.6)
                            safeEntity.playAllAnimations()
                            safeEntity.unfocus()
                            return true
                        }
                        return false
                    },
                    onInput: { _ in
                        safeEntity.playAudioWithName("keypad_click", speed: 1.5, volume: -3)
                    }
                )
            }
        }
        .simultaneousGesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { event in
                    if let target = event.entity.progenitor {
                        if let component = target.components[DragToMoveComponent.self] {
                            component.handleChange(event)
                        }
                    }
                }
                .onEnded { event in
                    if let target = event.entity.progenitor {
                        if let component = target.components[DragToMoveComponent.self] {
                            component.handleEnd(event)
                        }
                    }
                }
        )
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { event in
                    if let target = event.entity.progenitor {
                        if let component = target.components[RespondTapComponent.self] {
                            component.handle(event)
                        }
                    }
                }
        )
        .onAppear {
            backgroundMusic?.stop()
            backgroundMusic = Song(name: "whitemyth_bg").volume(0.3).loop().play()
        }
        .onDisappear {
            backgroundMusic?.stop()
        }
    }
}
