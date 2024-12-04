//
//  EscapeSpaceView.swift
//  De3ign
//
//  Created by Lemocuber on 2024/12/2.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct EscapeSpaceView: View {
    var scale: Float = 2
    var position: SIMD3<Float> = [0, 0, -1.5]

    init(scale: Float = 2, position: SIMD3<Float> = [0, 0, -1.5]) {
        self.scale = scale
        self.position = position
    }

    @State var safeEntity: Entity?
    @State var safeAttachment: Entity?
    @State var keyEntity: Entity?
    @State var doorLockEntity: Entity?
    @State var doorEntity: Entity?

    @State var safeKeypadInput: String = ""

    var body: some View {
        RealityView { content, attachments in
            let sceneEntity = try! await Entity(named: "Escape_", in: realityKitContentBundle)
            sceneEntity.scale = SIMD3<Float>(repeating: scale)
            sceneEntity.position = position
            content.add(sceneEntity)

            safeEntity = sceneEntity.findEntity(named: "safe_animated")!
            safeEntity!.generateCollisionShapes(recursive: true)
            safeEntity!.components.set(InputTargetComponent())
            safeEntity!.components.set(HoverEffectComponent())
            
            let offset: SIMD3<Float> = [
                safeEntity!.visualBounds(relativeTo: safeEntity!).max.x - 0.1,
                safeEntity!.visualBounds(relativeTo: safeEntity!).max.y - 0.52,
                0,
            ]
            safeAttachment = attachments.entity(for: "safe_keypad")
            safeEntity!.addChild(safeAttachment!, preservingWorldTransform: true)
            safeAttachment!.position = offset
            safeAttachment!.transform.rotation = simd_quatf(angle: .pi/2, axis: [0, 1, 0])
            safeAttachment!.isEnabled = false
            safeEntity!.components.set(MetadataComponent(name: "safe"))
            
            keyEntity = sceneEntity.findEntity(named: "doorkey")!
            keyEntity!.generateCollisionShapes(recursive: true)
            keyEntity!.components.set(InputTargetComponent())
            keyEntity!.components.set(HoverEffectComponent())
            keyEntity!.components.set(MetadataComponent(name: "key"))
            
            doorLockEntity = sceneEntity.findEntity(named: "doorlock")!
            doorEntity = sceneEntity.findEntity(named: "door_animated")!
        } update: { _, _ in
            if self.safeKeypadInput == "314159" {
                safeAttachment!.isEnabled = false
                safeEntity!.playAllAnimations()
                safeEntity!.components.remove(InputTargetComponent.self)
                safeEntity!.components.remove(HoverEffectComponent.self)
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
                        if target == self.keyEntity {
                            keyEntity!.position = event.convert(event.location3D, from: .local, to: keyEntity!.parent!)
                            let distance = keyEntity!.distance(to: doorLockEntity!)
                            if distance < 0.5 {
                                keyEntity!.isEnabled = false
                                doorEntity!.playAllAnimations()
                            }
                        }
                    }
                }
        )
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { event in
                    if let target = event.entity.progenitor {
                        if target == safeEntity {
                            safeAttachment!.isEnabled = !safeAttachment!.isEnabled
                        }
                    }
                }
        )
    }
}
