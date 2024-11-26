//
//  ContentView.swift
//  Tv_test
//
//  Created by Jovita on 2024/11/13.
//

//import SwiftUI
//import RealityKit
//
//struct ContentView: View {
//    var body: some View {
////        ModelContainerView(scale: 0.00003)
//        VideoPlayerView()
//            .padding()
//    }
//}

import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var showVideo = false
    
    var body: some View {
        ZStack {
            // 3D模型
            ModelContainerView(scale: 0.000035)//0.000035
            
            // 视频播放窗口
            if showVideo {
                GeometryReader { geometry in
                    VideoPlayerView()
                        .frame(width: 1280, height: 720)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        // 添加3D变换
                        .rotation3DEffect(
                            .degrees(0), // 可以调整角度
                            axis: (x: 0, y: 10, z: 0)
                        )
                        // 添加深度效果
                        .transform3D(
                            .init(
                                translationX: 0,
                                y: 0,
                                z: 0 // 调整这个值来改变视频窗口与模型的距离
                            )
                        )
                }
            }
        }
        .onAppear {
            // 延迟显示视频窗口，确保模型已加载
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showVideo = true
            }
        }
    }
}

// 扩展 View 以添加 3D 变换功能
extension View {
    func transform3D(_ transform: Transform3D) -> some View {
        self.modifier(Transform3DModifier(transform: transform))
    }
}

// 3D 变换修饰器
struct Transform3DModifier: ViewModifier {
    let transform: Transform3D
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(transform.rotationDegrees),
                axis: transform.rotationAxis
            )
            .offset(x: transform.translationX, y: transform.translationY)
    }
}

// 3D 变换数据结构
struct Transform3D {
    var translationX: CGFloat = 0
    var translationY: CGFloat = 0
    var translationZ: CGFloat = 0
    var rotationDegrees: Double = 0
    var rotationAxis: (x: CGFloat, y: CGFloat, z: CGFloat) = (0, 1, 0)
    
    init(translationX: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0,
         rotationDegrees: Double = 0,
         rotationAxis: (x: CGFloat, y: CGFloat, z: CGFloat) = (0, 1, 0)) {
        self.translationX = translationX
        self.translationY = y
        self.translationZ = z
        self.rotationDegrees = rotationDegrees
        self.rotationAxis = rotationAxis
    }
}
