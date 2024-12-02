//
//  De3ignApp.swift
//  De3ign
//
//  Created by xuchi on 2024/8/22.
//

import SwiftUI
import MixedRealityCapture
import OSLog

@MainActor
let logger = Logger(subsystem: "BasicApp", category: "general")

@main
struct De3ignApp: App {
    
    @State private var appModel = AppModel()
    @State private var captureModel = CaptureModel()

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
        
        // ====== Volumes ======
        WindowGroup(id: editableVolume) {
            EditableSpaceView(scale: 0.15, position: [-0.1, -0.3, 0])
                .ornament(attachmentAnchor: .scene(.bottomFront)) {
                    OrnamentView(spaceId: editableVolume)
                        .environment(appModel)
                }
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        
        WindowGroup(id: jovitaVolume) {
            JovitaSpaceView(scale: 0.15, position: [0, -0.4, 0.3])
                .environment(captureModel)
                .ornament(attachmentAnchor: .scene(.bottomFront)) {
                    OrnamentView(spaceId: jovitaSpace)
                        .environment(appModel)
                }
                .sessionManager(model: captureModel)
        }
        .windowStyle(.volumetric)
        
        WindowGroup(id: basketballVolume) {
            BasketballSpaceView(scale: 0.15, position: [0, -0.4, 0.3])
                .ornament(attachmentAnchor: .scene(.bottomFront)) {
                    OrnamentView(spaceId: basketballSpace)
                        .environment(appModel)
                }
        }
        .windowStyle(.volumetric)
        
        WindowGroup(id: superBrainVolume) {
            SuperBrainSpaceView(scale: 0.08, position: [-0.1, -0.3, 0])
                .ornament(attachmentAnchor: .scene(.bottomFront)) {
                    OrnamentView(spaceId: superBrainSpace)
                        .environment(appModel)
                }
        }
        .windowStyle(.volumetric)
        
        WindowGroup(id: templeVolume) {
            TempleSpaceView()
                .ornament(attachmentAnchor: .scene(.bottomFront)) {
                    OrnamentView(spaceId: templeSpace)
                        .environment(appModel)
                }
        }
        .windowStyle(.volumetric)
        
        // ====== Spaces ======
        ImmersiveSpace(id: jovitaSpace) {
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
        
        ImmersiveSpace(id: basketballSpace) {
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
        
        ImmersiveSpace(id: superBrainSpace) {
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
        
        ImmersiveSpace(id: templeSpace) {
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
