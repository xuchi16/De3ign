//
//  ContentView.swift
//  De3ign
//
//  Created by xuchi on 2024/8/22.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(AppModel.self) var appModel
    
    @State var savedRealms: [SavedRealm] = []
    
    var body: some View {
        VStack {
            VStack {
                Text("博吾馆")
                    .font(.system(size: 70, weight: .thin))
                    .shadow(color: .blue, radius: 5)
                    .shadow(color: .blue, radius: 5)
                    .shadow(color: .blue, radius: 50)
                Text("Realmefy")
                    .font(.system(size: 40, weight: .thin))
                    .shadow(color: .red, radius: 5)
                    .shadow(color: .red, radius: 5)
                    .shadow(color: .red, radius: 50)
            }
            
            // === Volumes ===
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 20) {
                    ForEach(0 ..< appModel.spaces.count, id: \.self) { index in
                        Button {
                            self.appModel.selectedSpace = appModel.spaces[index]
                            Task {
                                await openImmersiveSpace(id: appModel.spaces[index].spaceId)
                            }
                        } label: {
                            VStack {
                                Text(appModel.spaces[index].id)
                                    .font(.extraLargeTitle)
                                    .frame(width: 300, height: 200)
                                
                                VStack(alignment: .leading) {
                                    Text(appModel.spaces[index].name)
                                        .font(.title)
                                    
                                    Text(appModel.spaces[index].description)
                                        .font(.headline)
                                    
                                }
                                .padding(cardPadding)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(.ultraThinMaterial)
                            .hoverEffect()
                            .frame(width: 300)
                            .clipShape(.rect(cornerRadius: 10.0))
                        }
                        .buttonStyle(.borderless)
                    }
//                    ForEach(self.savedRealms) { realm in
//                        Button {
//                            self.appModel.editorEntities.disableAll()
//                            self.appModel.editorEntities.append(contentsOf: loadRealm(realm))
//                            self.appModel.selectedSpace = appModel.spaces[0]
//                            openWindow(id: appModel.spaces[0].volumeName)
//                        } label: {
//                            VStack {
//                                Text(realm.name)
//                                    .font(.extraLargeTitle)
//                                    .frame(width: 300, height: 200)
//                                
//                                VStack(alignment: .leading) {
//                                    Text(realm.name)
//                                        .font(.title)
//                                    
//                                    Text("user created space")
//                                        .font(.headline)
//                                }
//                                .padding(cardPadding)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            }
//                            .background(.ultraThinMaterial)
//                            .hoverEffect()
//                            .frame(width: 300)
//                            .clipShape(.rect(cornerRadius: 10.0))
//                        }
//                        .buttonStyle(.borderless)
//                    }
                }
            }
            .frame(height: 350)
            .padding()
            .glassBackgroundEffect()
            
        }
        .padding()
        .onAppear() {
            self.savedRealms = listRealms()
            appModel.savedRealmsChangedCallback = {
                self.savedRealms = listRealms()
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
