//
//  libraryModel.swift
//  De3ign
//
//  Created by Lemocuber on 2024/10/11.
//

import SwiftUI
import RealityKit
import RealityKitContent

class LibraryModel: Identifiable {
    let id = UUID()
    let name: String
    let resourceName: String
    
    init(name: String, resourceName: String) {
        self.name = name
        self.resourceName = resourceName
    }
    
    func asEntity() -> Entity {
        let entity = try! Entity.load(named: self.resourceName, in: realityKitContentBundle)
        entity.name = self.name
        entity.position = [0,0,0]
        entity.scale *= 0.1
        entity.components.set(MetadataComponent(id: self.id, name: self.name))
        entity.components.set(HoverEffectComponent())
        entity.components.set(InputTargetComponent())
        entity.generateCollisionShapes(recursive: true)
        return entity
    }
}

struct MetadataComponent: Component {
    let id: UUID
    let name: String
    var isAttachmentInstalled: Bool = false
}

// workaround, didn't manage to make class inheriting work
extension Entity {
    // well, the ancestor which is a LibraryModel
    var progenitor: Entity? {
        if let parent = self.parent {
            if parent.metadata != nil {
                return parent
            }
            return parent.progenitor
        }
        return nil
    }
    
    var metadata: MetadataComponent? {
        return self.components[MetadataComponent.self]
    }
    
    var interaction: InteractionComponent? {
        return self.components[InteractionComponent.self]
    }
    
    var isAttachmentInstalled: Bool {
        get {
            return self.components[MetadataComponent.self]?.isAttachmentInstalled ?? false
        }
        set(newValue) {
            self.components[MetadataComponent.self]?.isAttachmentInstalled = newValue
        }
    }
    
    var attachment: ViewAttachmentEntity? {
        for child in self.children {
            if type(of: child) == ViewAttachmentEntity.self {
                return child as? ViewAttachmentEntity
            }
            if let result = child.attachment {
                return result
            }
        }
        return nil
    }
}

extension [Entity] {
    func disableAll() {
        for item in self {
            item.isEnabled = false
        }
    }
}
