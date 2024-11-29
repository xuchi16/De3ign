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
                    // workaround, clearing the array produces buggy behavior for attachments
                    appModel.libraryEntities.disableAll()
                } label: {
                    Text("Clear All")
                }
                Button {
                    openWindow(id: saveRealmView)
                } label: {
                    Image(systemName: "books.vertical")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
            }
            else {
                ToggleImmersiveSpaceButton(name: spaceId)
            }
        }
    }
}
