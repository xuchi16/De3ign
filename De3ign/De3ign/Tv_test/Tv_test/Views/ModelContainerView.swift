//
//  Untitled.swift
//  Tv_test
//
//  Created by Jovita on 2024/11/13.
//


import SwiftUI
import RealityKit

struct ModelContainerView: View {

    let scale: Float
    
    init(scale: Float = 0.001) {//0.001
        self.scale = scale
    }
    
    var body: some View {
        RealityView { content in
            guard let modelEntity = try? await Entity(named: "LED_TV") else {
                print("Failed to load Scene model")
                return
            }
            
            content.add(modelEntity)
            
            modelEntity.position = SIMD3(x: 0, y: -0.16, z: 0.19)
            modelEntity.scale = SIMD3(x: scale, y: scale, z: scale)
            
            // 添加右转90度的旋转
            // 使用弧度：π/2 = 90度
            modelEntity.orientation = simd_quatf(angle: .pi/2, axis: SIMD3(x: 0, y: 1, z: 0))
        }
    }
}
