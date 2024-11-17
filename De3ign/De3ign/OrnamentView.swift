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
                    appModel.libraryEntities = []
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
