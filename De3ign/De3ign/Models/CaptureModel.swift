//
//  Capture.swift
//  De3ign
//
//  Created by xuchi on 2024/12/2.
//

import ARKit
//import MixedRealityCapture
import OSLog
import RealityKit
import SwiftUI

@Observable
@MainActor
class CaptureModel {
//    
//    private(set) var externalCameraEntity = Entity()
//
//    let session = ARKitSession()
//    let worldTracking = WorldTrackingProvider()
//    let imageTracking = MixedRealityImageTracking.imageTrackingProvider()
//
//    var mrcManager: MixedRealityCaptureManager
//
//    private(set) var contentEntity = Entity()
//
//    var hasError = false
//
//    var dataProvidersAreSupported: Bool {
//        WorldTrackingProvider.isSupported && ImageTrackingProvider.isSupported
//    }
//
//    var isReadyToRun: Bool {
//        worldTracking.state == .initialized && imageTracking.state == .initialized
//    }
//
//    init() {
//        // Instantiate the Mixed Reality Capture manager
//        self.mrcManager = MixedRealityCaptureManager()
//        mrcManager.delegate = self
//        
//        externalCameraEntity.position = Vector3(-1.5, 1.5, 0)
//        externalCameraEntity.addChild(MixedRealityCapture.EntityBuilder.makeGizmo())
//        contentEntity.addChild(externalCameraEntity)
//    }
//
//    func processImageTrackingUpdates() async {
//        for await update in imageTracking.anchorUpdates {
//            // Update the camera position and orientation when we
//            // detect the calibration image
//            mrcManager.updateCameraPosition(with: update.anchor)
//        }
//    }
//
//    func monitorSessionEvents() async {
//        for await event in session.events {
//            switch event {
//            case .authorizationChanged(type: _, status: let status):
//                logger.info("Authorization changed to: \(status)")
//
//                if status == .denied {
//                    hasError = true
//                }
//            case .dataProviderStateChanged(dataProviders: let providers, newState: let state, error: let error):
//                logger.info("Data provider changed: \(providers), \(state)")
//                if let error {
//                    logger.error("Data provider reached an error state: \(error)")
//                    hasError = true
//                }
//            @unknown default:
//                fatalError("Unhandled new event type \(event)")
//            }
//        }
//    }
}

//extension CaptureModel: MixedRealityCaptureDelegate {
//    func didUpdateCamera(pose: Pose) {
//        // Optional: Update some entity in your scene that
//        // represents the position of the external camera
//        externalCameraEntity.transform = Transform(
//            scale: .init(1, 1, 1),
//            rotation: pose.rotation,
//            translation: pose.position
//        )
//    }
//}
