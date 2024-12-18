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
        target.position = event.convert(event.location3D, from: .local, to: target.parent!)

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
