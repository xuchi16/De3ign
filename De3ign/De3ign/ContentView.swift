//
//  ContentView.swift
//  De3ign
//
//  Created by xuchi on 2024/8/22.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @Environment(\.openWindow) var openWindow
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        VStack {
            Text("De3ign")
                .font(.system(size: 70, weight: .thin))
                .shadow(color: .blue, radius: 5)
                .shadow(color: .blue, radius: 5)
                .shadow(color: .blue, radius: 50)
            
            // === Volumes ===
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 20) {
                    ForEach(0 ..< appModel.spaces.count, id: \.self) { index in
                        VStack {
                            Image(appModel.spaces[index].name)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(30)
                            
                            Text(appModel.spaces[index].name)
                                .font(.title)
                        }
                        .padding()
                        .glassBackgroundEffect()
                        .onTapGesture {
                            self.appModel.selectedSpace = appModel.spaces[index]
                            openWindow(id: appModel.spaces[index].volumeName)
                        }
                    }
                }
            }
            .frame(height: 350)
            
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
