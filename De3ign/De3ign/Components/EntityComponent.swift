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

struct DragToMoveComponent: Component {
    let target: Entity
    func handleChange(_ event: EntityTargetValue<DragGesture.Value>) {
        if var physicsBody = target.components[PhysicsBodyComponent.self] {
            physicsBody.isAffectedByGravity = false
            target.components.set(physicsBody)
        }
        target.position = event.convert(event.location3D, from: .local, to: target.parent!)
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
