//
//  EntityExtension.swift
//  De3ign
//
//  Created by xuchi on 2024/12/2.
//

import RealityKit
import RealityKitContent
import SwiftUI

/*
 * util
 */
extension Entity {
    func playAllAnimations() {
        var controllers: [AnimationPlaybackController] = []
        for animation in self.availableAnimations {
            let controller = self.playAnimation(animation)
            controllers.append(controller)
        }
        self.components.set(AnimationStateComponent(isPlaying: true, controllers: controllers))
    }
    
    func pauseAllAnimations() {
        if let component = self.components[AnimationStateComponent.self] {
            for controller in component.controllers {
                controller.pause()
            }
            self.components.set(AnimationStateComponent(isPlaying: false, controllers: component.controllers))
        }
    }
    
    
    
    func toggleAllAnimations() {
        if let component = self.components[AnimationStateComponent.self] {
            if component.isPlaying {
                pauseAllAnimations()
            } else {
                playAllAnimations()
            }
        } else {
            playAllAnimations()
        }
    }
    
    func resumeAllAnimations() {
        if let component = self.components[AnimationStateComponent.self] {
            for controller in component.controllers {
                controller.resume()
            }
        }
    }
    
    func distance(to other: Entity) -> Float {
        let posA = self.position(relativeTo: nil)
        let posB = other.position(relativeTo: nil)
        return simd_distance(posA, posB)
    }
}

extension Entity {
    var progenitor: Entity? {
        if self.metadata != nil {
            return self
        }
        if let parent = self.parent {
            return parent.progenitor
        }
        return nil
    }
    
    var metadata: MetadataComponent? {
        return self.components[MetadataComponent.self]
    }
    
    func findChildAndSetMetadata(named name: String) -> Entity {
        print(name)
        let entity = self.findEntity(named: name)!
        entity.setMetadata(name: name)
        return entity
    }
    
    @discardableResult
    func setMetadata(name: String) -> Entity {
        self.components.set(MetadataComponent(name: name))
        return self
    }
    
    @discardableResult
    func draggable() -> Entity {
        self.components.set(DragToMoveComponent(target: self))
        return self
    }
    
    @discardableResult
    func whenDistance(to other: Entity, within threshold: Float, do callback: @escaping () -> Void) -> Entity {
        self.components.set(InteractOnDistanceComponent(other: other, threshold: threshold, callback: callback))
        return self
    }
    
    @discardableResult
    func whenDistance(
        to other: Entity, within threshold: Float, always multipleTrigger: Bool, do callback: @escaping () -> Void
    ) -> Entity {
        self.components.set(
            InteractOnDistanceComponent(
                other: other, threshold: threshold, callback: callback, multipleTrigger: multipleTrigger
            )
        )
        return self
    }
    
    @discardableResult
    func whenTapped(do callback: @escaping () -> Void) -> Entity {
        self.components.set(RespondTapComponent(target: self, callback: callback))
        return self
    }
    
    func unfocus() {
        self.components.remove(InputTargetComponent.self)
        self.components.remove(HoverEffectComponent.self)
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
            
            if type == "library" {
                entity = EditorLibraryObject(
                    name: data["name"]!,
                    resourceName: data["resourceName"]!
                ).asEntity()!
            }
            else if type == "genAi" {
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
