//
//  modelLibrary.swift
//  De3ign
//
//  Created by Lemocuber on 2024/10/11.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ModelLibraryView: View {
    
    @Environment(\.openWindow) var openWindow
    @Environment(AppModel.self) var appModel
    
    @State var items: [LibraryModel] = [
        LibraryModel(name: "Iphone", resourceName: "iphone"),
        LibraryModel(name: "Basketball", resourceName: "basketball"),
        LibraryModel(name: "Frostnova", resourceName: "Arknights_Originite_Prime")
    ]
    
    var body: some View {
        ScrollView {
            HStack(spacing: 20) {
                ForEach (items) { item in
                    Button(action: {
                        appModel.sceneLibraryModelList.append(
                            SceneLibraryModel(item)
                        )
                    }) {
                        VStack {
                            Model3D(named: item.resourceName, bundle: realityKitContentBundle) { model in
                                model
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 200, height: 200)
                            
                            Text(item.name)
                                .font(.headline)
                                .padding(.top, 10)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}
