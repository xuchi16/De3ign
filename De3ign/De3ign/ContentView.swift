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
            VStack {
                Text("博吾馆")
                    .font(.system(size: 70, weight: .thin))
                    .shadow(color: .blue, radius: 5)
                    .shadow(color: .blue, radius: 5)
                    .shadow(color: .blue, radius: 50)
                Text("Realmefy")
                    .font(.system(size: 40, weight: .thin))
                    .shadow(color: .red, radius: 5)
                    .shadow(color: .red, radius: 5)
                    .shadow(color: .red, radius: 50)
            }
            
            // === Volumes ===
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 20) {
                    ForEach(0 ..< appModel.spaces.count, id: \.self) { index in
                        Button {
                            self.appModel.selectedSpace = appModel.spaces[index]
                            openWindow(id: appModel.spaces[index].volumeName)
                        } label: {
                            VStack {
                                Image(appModel.spaces[index].id)
                                    .resizable()
                                    .frame(width: 300, height: 200)
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading) {
                                    Text(appModel.spaces[index].name)
                                        .font(.title)
                                    
                                    Text(appModel.spaces[index].description)
                                        .font(.headline)
                                    
                                }
                                .padding(cardPadding)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(.ultraThinMaterial)
                            .hoverEffect()
                            .frame(width: 300)
                            .clipShape(.rect(cornerRadius: 10.0))
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .frame(height: 350)
            .padding()
            .glassBackgroundEffect()
            
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
