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
    func playAnimationWithName(_ name: String, speed: Float = 1) {
        for anim in self.availableAnimations {
            if anim.name == name {
                let controller = self.playAnimation(anim)
                controller.speed = speed
                return
            }
        }
        fatalError("animation \(name) not found on \(self.name)")
    }
    
    func playAllAnimations(loop repeated: Bool = false) {
        var controllers: [AnimationPlaybackController] = []
        for anim in self.availableAnimations {
            var animation = anim
            if repeated {
                animation = anim.repeat(count: .max)
            }
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
    
    func playAudioWithName(_ name: String, speed: Float = 1, volume: Float = 0.0) {
        let library = self.components[AudioLibraryComponent.self]!
        let resource = library.resources[name]!
        let controller = self.playAudio(resource)
        controller.speed = Double(speed)
        controller.gain = Double(volume)
    }
    
    func playAllAudios(loop repeated: Bool = false) {
        if let library = self.components[AudioLibraryComponent.self] {
            for resource in library.resources.values {
                let controller = self.playAudio(resource)
                if repeated {
                    controller.completionHandler = {
                        controller.play()
                    }
                }
            }
        }
    }
    
    func distance(to other: Entity) -> Float {
        let posA = self.position(relativeTo: nil)
        let posB = other.position(relativeTo: nil)
        return simd_distance(posA, posB)
    }
    
    func magneticMove(to other: Entity, duration seconds: Float) async {
        let transform = Transform(
            scale: self.scale(relativeTo: nil),
            rotation: self.transform.rotation,
            translation: other.position(relativeTo: nil)
        )
        self.move(to: transform, relativeTo: nil, duration: .init(floatLiteral: Double(seconds)), timingFunction: .easeOut)
        try! await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
    
    func findAllChildrenWithComponent<T: Component>(_ componentType: T.Type, excludingDescendants: Bool = true) -> [Entity]  {
        var result: [Entity] = []
        
        if self.components[componentType] != nil {
            result.append(self)
            
            // return early when we assume an entity having the given component won't have any child that does so
            if excludingDescendants {
                return result
            }
        }
        
        for child in self.children {
            result.append(contentsOf: child.findAllChildrenWithComponent(componentType, excludingDescendants: excludingDescendants))
        }
        
        return result
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
        let entity = self.findEntity(named: name)!
        entity.setMetadata(name: name)
        return entity
    }
    
    func firstModelEntity() -> ModelEntity? {
        if type(of: self) == ModelEntity.self {
            return self as? ModelEntity
        }
        for child in self.children {
            if let result = child.firstModelEntity() {
                return result
            }
        }
        return nil
    }
    
    func findParticleEmittingEntity() -> Entity? {
        if self.components[ParticleEmitterComponent.self] != nil {
            return self
        }
        for child in self.children {
            if let entity = child.findParticleEmittingEntity() {
                return entity
            }
        }
        return nil
    }
    
    func particleBurst() {
        self.findParticleEmittingEntity()?.components[ParticleEmitterComponent.self]!.burst()
    }
    
    @discardableResult
    func setMetadata(name: String) -> Entity {
        self.components.set(MetadataComponent(name: name))
        return self
    }
    
    @discardableResult
    func draggable(_ outOfBoundChecker: ((SIMD3<Float>) -> Bool)? = nil) -> Entity {
        let dragComponent = DragToMoveComponent(target: self)
        self.components.set(dragComponent)
        if dragComponent.isUsingPhysics && outOfBoundChecker != nil {
            self.components.set(PositionGuardComponent(
                initialPosition: self.position,
                checkIsOutOfBoundary: outOfBoundChecker!
            ))
        }
        return self
    }
    
    @discardableResult
    func whenDistance(
        to other: Entity, within threshold: Float, always multipleTrigger: Bool = false, do callback: @escaping () -> Void
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
    
    @discardableResult
    func whenCollided(with other: Entity, content: RealityViewContent, withSoundEffect sfxName: String? = nil, do callback: @escaping () -> Void) -> Entity {
        self.components.set(
            CollisionHandlerComponent(
                target: self, other: other, content: content, sfxName: sfxName, callback: callback
            )
        )
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
            } else if type == "genAi" {
                entity = EditorGenAiObject(
                    name: data["name"]!,
                    url: getGenAiModelsDirectory().appendingPathComponent(data["fileName"]!)
                ).asEntity()!
            } else {
                return nil
            }
            
            entity.transform = try! jsonD.decode(Transform.self, from: Data(data["transform"]!.utf8))
            
            return entity
        }
        return nil
    }
}
