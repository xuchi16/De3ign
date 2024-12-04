//
//  libraryModel.swift
//  De3ign
//
//  Created by Lemocuber on 2024/10/11.
//

import SwiftUI
import RealityKit
import RealityKitContent

// couldn't create type LibraryModel | GenAiModel
protocol EditorSceneUsing: Identifiable {
    var id: UUID { get }
    var name: String { get }
    func asEntity() -> Entity?
}

class EditorLibraryObject: Identifiable, EditorSceneUsing {
    let id = UUID()
    let name: String
    let resourceName: String
    
    init(name: String, resourceName: String) {
        self.name = name
        self.resourceName = resourceName
    }
    
    func asEntity() -> Entity? {
        let entity = try! Entity.load(named: self.resourceName, in: realityKitContentBundle)
        entity.name = self.name
        entity.position = [0,0,0]
        entity.scale *= 0.1
        entity.components.set(EditorMetadataComponent(id: self.id, name: self.name, source: .library(self)))
        entity.components.set(HoverEffectComponent())
        entity.components.set(InputTargetComponent())
        entity.generateCollisionShapes(recursive: true)
        return entity
    }
}

struct EditorMetadataComponent: Component {
    let id: UUID
    let name: String
    var isAttachmentInstalled: Bool = false
    let source: EntitySource
}
