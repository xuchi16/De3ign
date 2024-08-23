//
//  TempleSpaceView.swift
//  De3ign
//
//  Created by xuchi on 2024/8/23.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct TempleSpaceView: View {
    // Volume: 0.15, Space: 0.3
    var scale: Float = 0.3
    var position: SIMD3<Float> = [0, 1, -1.5]
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "JovitaScene", in: realityKitContentBundle) {
                immersiveContentEntity.scale = SIMD3<Float>(repeating: scale)
                immersiveContentEntity.position = position
                content.add(immersiveContentEntity)
                
                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
    }
}

#Preview {
    TempleSpaceView()
}
