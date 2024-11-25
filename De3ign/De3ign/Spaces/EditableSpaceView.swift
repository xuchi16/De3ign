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
        RealityView { content, attachments in
            let scene = try! await Entity(named: "Editable", in: realityKitContentBundle)
            scene.scale = SIMD3<Float>(repeating: scale)
            scene.position = position
            
            content.add(scene)
            content.add(libraryModelWrapper)
            
            placeLibraryModels(appModel.libraryEntities)
            
            appModel.libraryEntitiesChangedCallback = {
                placeLibraryModels(appModel.libraryEntities)
            }
        } update: { content, attachments in
            self.libraryModelWrapper.children.forEach { child in
                child.removeFromParent()
            }
            for (index, item) in self.models.enumerated() {
                libraryModelWrapper.addChild(item)
                if !item.isAttachmentInstalled {
                    if let attachment = attachments.entity(for: "\(index)") {
                        let offset = /* bottom of entity */ item.visualBounds(relativeTo: item).min.y - /* ~attachment height */ 30
                        
                        item.addChild(attachment, preservingWorldTransform: true)
                        
                        attachment.position = [0, offset, 0]
                        attachment.isEnabled = false
                        
                        item.isAttachmentInstalled = true
                    }
                }
            }
        } attachments: {
            ForEach(0..<500, id: \.self) { id in
                Attachment(id: "\(id)") {
                    InteractionSelectorAttachmentView(appModel: appModel, id: id)
                }
            }
            
        }
        .onDisappear {
            appModel.libraryEntities.disableAll()
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
            TapGesture(count: 2)
                .targetedToAnyEntity()
                .onEnded { event in
                    if event.entity.progenitor?.isAttachmentInstalled ?? false {
                        if let attachment = event.entity.progenitor!.attachment {
                            attachment.isEnabled = !attachment.isEnabled
                        }
                    }
                }
        )
        .gesture(
            TapGesture(count: 1)
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
//        libraryModelWrapper.children.forEach { child in
//            child.removeFromParent()
//        }
//        for item in models {
//            libraryModelWrapper.addChild(item)
//        }
    }
}

#Preview {
    EditableSpaceView()
}
