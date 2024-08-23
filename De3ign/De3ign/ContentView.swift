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
    
    var body: some View {
        VStack {
            Text("De3ign")
                .font(.title)
            
            HStack {
                VStack {
                    Text("JovitaSpace")
                    Button("Enter") {
                        openWindow(id: jovitaVolume)
                    }
                }
                
                VStack {
                    Text("BasketballSpace")
                    ToggleImmersiveSpaceButton(name: basketballSpace)
                }
                
                VStack {
                    Text("SuperBrainSpace")
                    ToggleImmersiveSpaceButton(name: superBrainSpace)
                }
                
                VStack {
                    Text("MythSpace")
                    ToggleImmersiveSpaceButton(name: templeSpace)
                }
            }
            
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
