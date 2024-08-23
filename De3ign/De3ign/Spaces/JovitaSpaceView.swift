//
//  JovitaSpaceView.swift
//  De3ign
//
//  Created by xuchi on 2024/8/22.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct JovitaSpaceView: View {
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Jovita_scene", in: realityKitContentBundle) {
                immersiveContentEntity.scale = SIMD3<Float>(repeating: 0.3)
                immersiveContentEntity.position = [0, 1, -1.5]
                content.add(immersiveContentEntity)
                
                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
    }
}

#Preview {
    JovitaSpaceView()
}
