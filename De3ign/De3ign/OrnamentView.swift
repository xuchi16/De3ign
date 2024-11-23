//
//  OrnamentView.swift
//  De3ign
//
//  Created by xuchi on 2024/8/23.
//

import SwiftUI

struct OrnamentView: View {
    
    @Environment(\.openWindow) var openWindow
    @Environment(AppModel.self) var appModel
    
    var spaceId: String
    var body: some View {
        HStack(spacing: 20) {
            if (spaceId == editableVolume) {
                Button {
                    openWindow(id: modelLibrary)
                } label: {
                    Text("Open Model Library")
                }
                Button {
                    while(!appModel.libraryEntities.isEmpty) {
                        let _ = appModel.libraryEntities.popLast()
                    }
                    appModel.libraryEntitiesChangedCallback?()
                } label: {
                    Text("Clear All")
                }
            }
            else {
                ToggleImmersiveSpaceButton(name: spaceId)
            }
        }
        .glassBackgroundEffect()
    }
}
