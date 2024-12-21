//
//  De3ignApp.swift
//  De3ign
/// Users/lemoc/Downloads/SnowGlobePractice/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets/Scene.usda
//  Created by xuchi on 2024/8/22.
//

import SwiftUI
// import MixedRealityCapture
import OSLog
import RealityKitContent

@MainActor
let logger = Logger(subsystem: "BasicApp", category: "general")

@main
struct De3ignApp: App {
    @State private var appModel = AppModel()
    @State private var captureModel = CaptureModel()

    init() {
        RealityKitContent.HasHoverEffectComponent.registerComponent()
    }
    
    var body: some Scene {
        // debug
        let _ = print(getGenAiModelsDirectory())
        
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        
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
        
        // ====== Windows ======
        WindowGroup(id: modelLibrary) {
            ModelLibraryView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        
        WindowGroup(id: saveRealmView) {
            SaveRealmView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        
        // ====== Spaces ======
        ImmersiveSpace(id: SpaceID.escapeSpace.rawValue) {
            EscapeSpaceView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        
        ImmersiveSpace(id: SpaceID.whiteMythSpace.rawValue) {
            WhiteMythSpaceView(scale: nil, position: nil)
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        ImmersiveSpace(id: yogaSpace) {
            YogaSpace()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        
        ImmersiveSpace(id: SpaceID.jovitaSpace.rawValue) {
            JovitaSpaceView(scale: 2)
                .environment(appModel)
                .environment(captureModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        ImmersiveSpace(id: SpaceID.basketballSpace.rawValue) {
            BasketballSpaceView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        ImmersiveSpace(id: SpaceID.superBrainSpace.rawValue) {
            SuperBrainSpaceView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        ImmersiveSpace(id: SpaceID.templeSpace.rawValue) {
            TempleSpaceView()
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
