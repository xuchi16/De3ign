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
    var scale: Float = 2
    var position: SIMD3<Float> = [0, 0, -1.5]

    init(scale: Float?, position: SIMD3<Float>?) {
        self.scale = scale ?? self.scale
        self.position = position ?? self.position
    }
    
    let PASSWORD = "123456"

    @State var windowEntity = Entity()
    @State var lighterEntity = Entity()
    @State var candleEntity = Entity()
    @State var candleFireEntity = Entity()
    @State var paperEntity = Entity()
    @State var dresserEntity = Entity()
    @State var hammerEntity = Entity()
    @State var breakableFloorEntity = Entity()
    @State var dresserKeyEntity = Entity()
    @State var batteryEntity = Entity()
    @State var snowGlobeEntity = Entity()
    @State var photoFrameEntity = Entity()
    @State var safeEntity = Entity()
    @State var doorkeyEntity = Entity()
    @State var doorLockAnchorEntity = Entity()
    @State var doorEntity = Entity()
    
    @State var safeAttachment: Entity = Entity()

    @State var isCandleLit = false
    @State var safeKeypadInput: String = ""
    
    var body: some View {
        RealityView { content, attachments in
            let sceneEntity = try! await Entity(named: "WhiteMyth", in: realityKitContentBundle)
            sceneEntity.scale = SIMD3<Float>(repeating: scale)
            sceneEntity.position = position
            content.add(sceneEntity)

            windowEntity = sceneEntity.findChildAndSetMetadata(named: "window_animated")
            lighterEntity = sceneEntity.findChildAndSetMetadata(named: "lighter")
            candleEntity = sceneEntity.findChildAndSetMetadata(named: "candle")
            candleFireEntity = sceneEntity.findChildAndSetMetadata(named: "candlefire")
            paperEntity = sceneEntity.findChildAndSetMetadata(named: "paper")
            dresserEntity = sceneEntity.findChildAndSetMetadata(named: "dresser")
            hammerEntity = sceneEntity.findChildAndSetMetadata(named: "hammer")
            breakableFloorEntity = sceneEntity.findChildAndSetMetadata(named: "breakablefloor")
            dresserKeyEntity = sceneEntity.findChildAndSetMetadata(named: "dresserkey")
            batteryEntity = sceneEntity.findChildAndSetMetadata(named: "battery")
            snowGlobeEntity = sceneEntity.findChildAndSetMetadata(named: "snowglobe")
            photoFrameEntity = sceneEntity.findChildAndSetMetadata(named: "photoframe")
            safeEntity = sceneEntity.findChildAndSetMetadata(named: "safe_animated")
            doorkeyEntity = sceneEntity.findChildAndSetMetadata(named: "doorkey")
            doorLockAnchorEntity = sceneEntity.findChildAndSetMetadata(named: "anchor_doorlock")
            doorEntity = sceneEntity.findChildAndSetMetadata(named: "door_animated")
            
            safeAttachment = attachments.entity(for: "safe_keypad")!
            safeEntity.addChild(safeAttachment, preservingWorldTransform: true)
            safeAttachment.position = [
                safeEntity.visualBounds(relativeTo: safeEntity).max.x - 0.1,
                safeEntity.visualBounds(relativeTo: safeEntity).max.y - 0.1,
                0,
            ]
            //safeAttachment.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
            //safeAttachment.isEnabled = false
            
            windowEntity.whenTapped {
                windowEntity.toggleAllAnimations()
            }
            
            lighterEntity.draggable().whenDistance(to: candleEntity, within: 0.2) {
                print("on fire!")
                candleFireEntity.isEnabled = true
                isCandleLit = true
            }
            
            paperEntity.draggable().whenDistance(to: candleEntity, within: 0.2) {
                if !isCandleLit {
                    print("candle unlit")
                    return
                }
                print("paper says 16")
            }
            
            dresserEntity.whenTapped {
                dresserEntity.playAllAnimations()
            }
            
            batteryEntity.draggable().whenDistance(to: snowGlobeEntity, within: 0.2) {
                snowGlobeEntity.playAllAnimations()
            }
            
            safeEntity.whenTapped {
                safeAttachment.isEnabled.toggle()
            }
            
            doorkeyEntity.draggable().whenDistance(to: doorLockAnchorEntity, within: 0.5) {
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
                            component.handle(event)
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
