//
//  De3ignApp.swift
//  De3ign
//
//  Created by xuchi on 2024/8/22.
//

import SwiftUI

@main
struct De3ignApp: App {

    @State private var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        // ========================= Volumes =========================
        
        WindowGroup(id: jovitaVolume) {
            JovitaSpaceView(scale: 0.15, position: [0, 0, 0])
        }
        .windowStyle(.volumetric)
        
        WindowGroup(id: basketballVolume) {
            BasketballSpaceView()
        }
        .windowStyle(.volumetric)
        
        WindowGroup(id: superBrainVolume) {
            SuperBrainSpaceView()
        }
        .windowStyle(.volumetric)
        
        WindowGroup(id: templeVolume) {
            TempleSpaceView()
        }
        .windowStyle(.volumetric)
        
        // ========================= Spaces =========================
        ImmersiveSpace(id: jovitaSpace) {
            JovitaSpaceView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        ImmersiveSpace(id: basketballSpace) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        ImmersiveSpace(id: superBrainSpace) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        ImmersiveSpace(id: templeSpace) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
