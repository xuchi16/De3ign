//
//  EntityExtension.swift
//  De3ign
//
//  Created by xuchi on 2024/12/2.
//

import SwiftUI
import RealityKit
import RealityKitContent

/*
 * util
 */
extension Entity {
    func playAllAnimations() {
        for animation in self.availableAnimations {
            self.playAnimation(animation)
        }
    }
    
    func distance(to other: Entity) -> Float {
        let posA = self.position(relativeTo: nil)
        let posB = other.position(relativeTo: nil)
        return simd_distance(posA, posB)
    }
}

struct MetadataComponent: Component {
    let name: String
}

extension Entity {
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
}

/*
 * editor
 */
extension Entity {
    var editorProgenitor: Entity? {
        if let parent = self.parent {
            if parent.editorMetadata != nil {
                return parent
            }
            return parent.editorProgenitor
        }
        return nil
    }
    
    var editorMetadata: EditorMetadataComponent? {
        return self.components[EditorMetadataComponent.self]
    }
    
    var editorInteraction: EditorInteractionComponent? {
        return self.components[EditorInteractionComponent.self]
    }
    
    var isAttachmentInstalled: Bool {
        get {
            return self.components[EditorMetadataComponent.self]?.isAttachmentInstalled ?? false
        }
        set(newValue) {
            self.components[EditorMetadataComponent.self]?.isAttachmentInstalled = newValue
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

/*
 * save load
 */
extension Entity {
    func toBaseData() -> EntityBaseData? {
        if let metadata = self.editorMetadata {
            switch metadata.source {
                
            case .library(let model):
                return [
                    "type": "library",
                    "name": model.name,
                    "resourceName": model.resourceName,
                    "transform": try! String(data: jsonE.encode(self.transform), encoding: .utf8)!
                ]
            case .genAi(let model):
                return [
                    "type": "genAi",
                    "name": model.name,
                    "fileName": model.url!.lastPathComponent,
                    "transform": try! String(data: jsonE.encode(self.transform), encoding: .utf8)!
                ]
            }
        }
        return nil
    }
    
    static func fromBaseData(data: EntityBaseData) -> Entity? {
        if let type = data["type"] {
            var entity: Entity
            
            if (type == "library") {
                entity = EditorLibraryObject(
                    name: data["name"]!,
                    resourceName: data["resourceName"]!
                ).asEntity()!
            }
            else if (type == "genAi") {
                entity = EditorGenAiObject(
                    name: data["name"]!,
                    url: getGenAiModelsDirectory().appendingPathComponent(data["fileName"]!)
                ).asEntity()!
            }
            else {
                return nil
            }
            
            entity.transform = try! jsonD.decode(Transform.self, from: Data(data["transform"]!.utf8))
            
            return entity
        }
        return nil
    }
}
