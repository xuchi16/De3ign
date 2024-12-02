//
//  SessionManagerModifier.swift
//  De3ign
//
//  Created by xuchi on 2024/12/2.
//

import OSLog
import SwiftUI

struct SessionManagerModifier: ViewModifier {
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow

    let model: CaptureModel

    func body(content: Content) -> some View {
        content
//            .task {
//                do {
//                    if model.dataProvidersAreSupported && model.isReadyToRun {
//                        print("Try to connect!")
//                        try await model.session.run([model.imageTracking, model.worldTracking])
//                    } else {
//                        await dismissImmersiveSpace()
//                    }
//                } catch {
//                    logger.error("Failed to start session: \(error)")
//                    await dismissImmersiveSpace()
//                    openWindow(id: "error")
//                }
//            }
//            .task {
//                await model.processImageTrackingUpdates()
//            }
//            .task {
//                await model.monitorSessionEvents()
//            }
//            .onChange(of: model.hasError) {
//                openWindow(id: "error")
//            }
    }
}

// 创建便捷的 View 修饰符扩展
extension View {
    func sessionManager(model: CaptureModel) -> some View {
        modifier(SessionManagerModifier(model: model))
    }
}
