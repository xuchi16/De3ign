//
//  EditableSpaceView.swift
//  De3ign
//
//  Created by Lemocuber on 2024/10/12.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct EditableSpaceView: View {
    
    @Environment(AppModel.self) var appModel
    
    var scale: Float = 2
    var position: SIMD3<Float> = [0, 0, -1.5]
    
    let libraryModels = Entity()
    
    init(scale: Float = 2, position: SIMD3<Float> = [0, 0, -1.5]) {
        self.scale = scale
        self.position = position
    }
    
    var body: some View {
        RealityView { content in
            let scene = try! await Entity(named: "Editable", in: realityKitContentBundle)
            scene.scale = SIMD3<Float>(repeating: scale)
            scene.position = position
            
            content.add(scene)
            content.add(libraryModels)
            
            placeLibraryModels(appModel.sceneLibraryModelList)
            
            appModel.sceneLibraryModelListChangedCallback = { value in
                placeLibraryModels(appModel.sceneLibraryModelList)
            }
        }
        .simultaneousGesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { event in
                    event.entity.position = event.convert(event.location3D, from: .local, to: event.entity.parent!)
                }
        )
    }
    
    func placeLibraryModels(_ models: [SceneLibraryModel]) {
        libraryModels.children.forEach { child in
            child.removeFromParent()
        }
        for item in models {
            libraryModels.addChild(item.entity)
            item.entity.components.set(HoverEffectComponent())
            item.entity.components.set(InputTargetComponent())
            item.entity.generateCollisionShapes(recursive: true)
        }
    }
}

#Preview {
    EditableSpaceView()
}
