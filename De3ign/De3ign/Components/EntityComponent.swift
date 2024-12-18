//
//  EntityComponent.swift
//  De3ign
//
//  Created by Lemocuber on 2024/12/5.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct MetadataComponent: Component {
    let name: String
}

struct EditorMetadataComponent: Component {
    let id: UUID
    let name: String
    var isAttachmentInstalled: Bool = false
    let source: EntitySource
}

private struct StartPositionComponent: Component {
    var value: SIMD3<Float>? = nil
}

struct DragToMoveComponent: Component {
    let target: Entity
    
    init(target: Entity) {
        self.target = target
        target.components.set(StartPositionComponent())
    }
    
    func handleChange(_ event: EntityTargetValue<DragGesture.Value>) {
        // move by force if has physics
        if var physicsBody = target.components[PhysicsBodyComponent.self] {
            physicsBody.isAffectedByGravity = false
            
            if (target.components[StartPositionComponent.self]?.value == nil) {
                target.components.set(StartPositionComponent(value: target.position(relativeTo: nil)))
            }
            let startPosition = target.components[StartPositionComponent.self]!.value!
            let targetPosition = event.convert(event.location3D, from: .local, to: .scene)
            let eventPosition = startPosition + targetPosition
            let entityPosition = target.position(relativeTo: nil)
            
            print("\(entityPosition)-\(eventPosition)")
            
            let direction = eventPosition - entityPosition
            var strength = length(direction)
            
            if strength < 1.0 {
                strength *= strength
            }
            
            print("\(direction):\(strength)")
            
            let forceFactor: Float = 0.01
            let force = forceFactor * simd_normalize(direction)
            
            print(force)
            
            (target as! HasPhysicsBody).addForce(force, relativeTo: nil)
        }
        // move by setting position otherwise
        else {
            target.position = event.convert(event.location3D, from: .local, to: target.parent!)
        }
        // trigger on distance event when applicable
        if let interaction = target.components[InteractOnDistanceComponent.self] {
            if target.distance(to: interaction.other) < interaction.threshold {
                interaction.callback()
                if !interaction.multipleTrigger {
                    target.components.remove(InteractOnDistanceComponent.self)
                }
            }
        }
    }

    func handleEnd(_ event: EntityTargetValue<DragGesture.Value>) {
        target.components.set(StartPositionComponent())
        if var physicsBody = target.components[PhysicsBodyComponent.self] {
            physicsBody.isAffectedByGravity = true
            target.components.set(physicsBody)
        }
    }
}

class CollisionHandlerComponent: Component {
    let target: Entity
    let other: Entity
    let content: RealityViewContent
    let callback: () -> Void
    private var handler: EventSubscription?

    init(target: Entity, other: Entity, content: RealityViewContent, callback: @escaping () -> Void) {
        self.target = target
        self.other = other
        self.content = content
        self.callback = callback

        self.handler = content.subscribe(to: CollisionEvents.Began.self, on: target) { event in
            if event.entityB == other {
                callback()
                self.handler?.cancel()
            }
        }
    }
}

struct RespondTapComponent: Component {
    let target: Entity
    let callback: () -> Void
    func handle(_ event: EntityTargetValue<TapGesture.Value>) {
        callback()
    }
}

struct InteractOnDistanceComponent: Component {
    let other: Entity
    let threshold: Float
    let callback: () -> Void
    var multipleTrigger = false
}

struct AnimationStateComponent: Component {
    var isPlaying: Bool
    var controllers: [AnimationPlaybackController]
}
