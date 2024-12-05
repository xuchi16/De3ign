//
//  EntityComponent.swift
//  De3ign
//
//  Created by Lemocuber on 2024/12/5.
//

import SwiftUI
import RealityKit
import RealityKitContent

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
    func handle(_ event: EntityTargetValue<DragGesture.Value>) {
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
