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
        LibraryModel(name: "Frostnova", resourceName: "Arknights_Originite_Prime"),
        LibraryModel(name: "Xiang", resourceName: "shangxiang"),
        LibraryModel(name: "Music Player", resourceName: "Carvaan_Music_Player"),
        LibraryModel(name: "Robot", resourceName: "Cute_Home_Robot"),
        LibraryModel(name: "T-Rex", resourceName: "Tyrannosarus_rex_Free_model"),
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Select a Model")
                    .font(.title2)
                    .padding(.vertical, 80)
                
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(), count: 4),
                        spacing: 50
                    ) {
                        ForEach (items) { item in
                            NavigationLink(destination: InteractionLibraryView(appModel: appModel, selectedModel: item)) {
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
    }
}
