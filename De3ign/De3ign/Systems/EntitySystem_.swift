//
//  1.swift
//  De3ign
//
//  Created by Lemocuber on 2024/12/19.
//

import RealityKit

class PositionGuardSystem: System {
    private static let query = EntityQuery(where: .has(PositionGuardComponent.self))
    private var cnt = 0

    required init(scene: Scene) {}
    func update(context: SceneUpdateContext) {
        for entity in context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        ) {
            let component = entity.components[PositionGuardComponent.self]!
            if component.checkIsOutOfBoundary(entity.position) {
                let physicsBody = entity.components[PhysicsBodyComponent.self]
                if physicsBody != nil {
                    Task {
                        entity.components.remove(PhysicsBodyComponent.self)
                        entity.position = component.initialPosition
                        try! await Task.sleep(nanoseconds: 0_001_000_000)
                        entity.components.set(physicsBody!)
                    }
                }
                else {
                    entity.position = component.initialPosition
                }
                cnt += 1
                print("\(cnt) reset \(entity.name)")
            }
        }
    }
}
