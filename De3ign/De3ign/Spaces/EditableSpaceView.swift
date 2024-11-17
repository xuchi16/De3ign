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
    
    let libraryModelWrapper = Entity()
    @State var models: [Entity] = []
    
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
            content.add(libraryModelWrapper)
            
            placeLibraryModels(appModel.libraryEntities)
            
            appModel.libraryEntitiesChangedCallback = { value in
                placeLibraryModels(appModel.libraryEntities)
            }
        }
        .simultaneousGesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { event in
                    if let target = event.entity.progenitor {
                        target.position = event.convert(event.location3D, from: .local, to: target.parent!)
                    }
                }
        )
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded({ event in
                    if let callback = event.entity.progenitor?.interaction?.gesture.tap {
                        callback(event)
                    }
                })
        )
    }
    
    func placeLibraryModels(_ models: [Entity]) {
        self.models = models
        libraryModelWrapper.children.forEach { child in
            child.removeFromParent()
        }
        for item in models {
            libraryModelWrapper.addChild(item)
        }
    }
}

#Preview {
    EditableSpaceView()
}
