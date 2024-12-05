//
//  ContentView.swift
//  Tv_test
//
//  Created by Jovita on 2024/11/13.
//

import SwiftUI
import RealityKit

struct Tv_video: View {
    @State private var showVideo = false
    @State private var modelPosition: SIMD3<Float>?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 3D模型
                ModelContainerView(scale: 0.000035) { position in
                    self.modelPosition = position
                }
                
                // 视频播放窗口
                if showVideo, let position = modelPosition {
                    VideoPlayerView()
                        .aspectRatio(16/9, contentMode: .fit)  // 保持16:9比例
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2) 
                        .rotation3DEffect(
                            .degrees(0),
                            axis: (x: 0.0, y: -5, z: 0),
                            anchor: .top

                    )
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showVideo = true
            }
        }
    }
}
#Preview {
    Tv_video()
}
