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
    }
    
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
            safeEntity.addChild(safeAttachment, preservingWorldTransform: true)
            safeAttachment.position = [
                safeEntity.visualBounds(relativeTo: safeEntity).max.x - 0.1,
                safeEntity.visualBounds(relativeTo: safeEntity).max.y - 0.52,
                0,
            ]
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
                self.isWindowOpen.toggle()
                if isWindowOpen {
                    windowSwitchEntity.playAnimationWithName("on", speed: 100)
                    windowEntity.playAnimationWithName("open", speed: 2)
                } else {
                    windowSwitchEntity.playAnimationWithName("off", speed: 100)
                    windowEntity.playAnimationWithName("close", speed: 2)
                }
            }
            
            lightSwitchEntity.whenTapped {
                self.isLightOn.toggle()
                if isLightOn {
                    lightSwitchEntity.playAnimationWithName("on", speed: 100)
                    lightSourceEntity.isEnabled = true
                } else {
                    lightSwitchEntity.playAnimationWithName("off", speed: 100)
                    lightSourceEntity.isEnabled = false
                }
            }
            
            lighterEntity.draggable().whenDistance(to: candleFireEntity, within: 0.2) {
                print("on fire!")
                candleFireEntity.isEnabled = true
                isCandleLit = true
            }
            
            paperEntity.draggable().whenDistance(to: candleFireEntity, within: 0.2, always: true) {
                if !isCandleLit {
                    print("candle unlit")
                    return
                }
                paperEntity.firstModelEntity()!.model!.materials = paperHiddenMaterial
                print("paper says 16")
                paperEntity.components.remove(InteractOnDistanceComponent.self)
            }
            
            // dresserKeyEntity.draggable().whenCollided(with: dresserEntity, content: content) {
            dresserKeyEntity.draggable().whenDistance(to: dresserLockEntity, within: 0.2) {
                Task {
                    await dresserKeyEntity.magneticMove(to: dresserLockEntity, duration: 2)
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
                    try! await Task.sleep(nanoseconds: 3_000_000_000)
                    for i in 1 ... 200 {
                        cockroachEntity.scale *= 0.98
                        iphoneEntity.scale *= (0.98 * pow(-1, Float(i)))
                        try! await Task.sleep(nanoseconds: 0_100_000_000)
                    }
                    cockroachEntity.isEnabled = false
                    iphoneEntity.isEnabled = false
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
                    
                    photoFrameAltImageEntity.isEnabled = true
                }
            }
            
            // prevent hammer falling out of scene
            Task {
                while true {
                    if hammerEntity.position.y < -1 {
                        (hammerEntity as! HasPhysicsBody).resetPhysicsTransform(recursive: true)
                        hammerEntity.position = [5.33, 0.7, -0.88]
                    }
                    try! await Task.sleep(nanoseconds: 0_200_000_000)
                }
            }
            
            hammerEntity.draggable().whenCollided(with: breakableFloorEntity, content: content) {
                print("break")
                hammerEntity.isEnabled = false
                breakableFloorEntity.isEnabled = false
            }
            
            safeEntity.whenTapped {
                safeAttachment.isEnabled = true
            }
            
            doorkeyEntity.draggable().whenDistance(to: doorLockAnchorEntity, within: 0.3) {
                doorkeyEntity.isEnabled = false
                doorEntity.playAllAnimations()
                print("escape success!")
            }
            
        } update: { _, _ in
            if self.safeKeypadInput == PASSWORD {
                safeAttachment.isEnabled = false
                safeEntity.playAllAnimations()
                safeEntity.unfocus()
            }
        } attachments: {
            Attachment(id: "safe_keypad") {
                SafeKeypadView(input: $safeKeypadInput)
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
    }
}
