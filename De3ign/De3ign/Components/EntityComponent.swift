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

class DragToMoveComponent: Component {
    let target: Entity
    let forceFactor: Float
    let isUsingPhysics: Bool
    private var prevPosition: SIMD3<Float>?
    private var currentPosition: SIMD3<Float>?
    private var storedPhysicsBody: PhysicsBodyComponent?

    init(target: Entity, forceFactor: Float = 1.0) {
        self.target = target
        self.forceFactor = forceFactor
        isUsingPhysics = target.components[PhysicsBodyComponent.self] != nil
    }

    func handleChange(_ event: EntityTargetValue<DragGesture.Value>) {
        // hard set position
        target.position = event.convert(event.location3D, from: .local, to: target.parent!)
        // record state if target has physics
        if isUsingPhysics {
            if prevPosition == nil {
                prevPosition = target.position
            } else {
                prevPosition = currentPosition
            }
            currentPosition = target.position
            if storedPhysicsBody == nil {
                storedPhysicsBody = target.components[PhysicsBodyComponent.self]
                target.components.remove(PhysicsBodyComponent.self)
            }
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
        // apply momentum when has physics
        if isUsingPhysics {
            target.components.set(storedPhysicsBody!)

            if let currentPosition, let prevPosition {
                let direction = currentPosition - prevPosition

                let force = direction * forceFactor
                (target as! HasPhysicsBody).addForce(force, relativeTo: nil)
            }
            self.storedPhysicsBody = nil
            self.prevPosition = nil
            self.currentPosition = nil
        }
    }
}

struct PositionGuardComponent: Component {
    let initialPosition: SIMD3<Float>
    let checkIsOutOfBoundary: (SIMD3<Float>) -> Bool
}

class CollisionHandlerComponent: Component {
    let target: Entity
    let other: Entity
    let content: RealityViewContent
    let sfxName: String?
    let callback: () -> Void
    private var handler: EventSubscription?

    init(target: Entity, other: Entity, content: RealityViewContent, sfxName: String? = nil, callback: @escaping () -> Void) {
        self.target = target
        self.other = other
        self.content = content
        self.sfxName = sfxName
        self.callback = callback

        self.handler = content.subscribe(to: CollisionEvents.Began.self, on: target) { event in
            if self.sfxName != nil {
                target.playAudioWithName(self.sfxName!)
            }
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
