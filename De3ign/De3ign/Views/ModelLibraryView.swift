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
    
    var body: some View {
        
        TabView() {
            Tab("Library", systemImage: "books.vertical") {
                PresetModelLibraryView(appModel: appModel)
                    .glassBackgroundEffect()
            }
            Tab("AI Generated", systemImage: "bubble.and.pencil") {
                GenAIModelLibraryView(appModel: appModel)
                    .glassBackgroundEffect()
            }
        }
        /**/
    }
}

struct PresetModelLibraryView: View {
    var appModel: AppModel
    
    let items: [EditorLibraryObject] = [
        EditorLibraryObject(name: "Iphone", resourceName: "iphone"),
        EditorLibraryObject(name: "Basketball", resourceName: "basketball"),
        EditorLibraryObject(name: "Frostnova", resourceName: "Arknights_Originite_Prime"),
        EditorLibraryObject(name: "Xiang", resourceName: "shangxiang"),
        EditorLibraryObject(name: "Music Player", resourceName: "Carvaan_Music_Player")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select a Model")
                .font(.title2)
                .padding(.vertical, 20)
            
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(), count: 4),
                    spacing: 50
                ) {
                    ForEach (items) { item in
                        Button {
                            if let entity = item.asEntity() {
                                appModel.editorEntities.append(entity)
                            }
                        } label: {
                            PresetItemBlock(item: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct GenAIModelLibraryView: View {
    var appModel: AppModel
    
    @State var items: [EditorGenAiObject] = EditorGenAiObject.listModels()
    
    @State var promptText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select or Generate a Model")
                .font(.title2)
                .padding(.vertical, 20)
            
            HStack(spacing: 10) {
                SearchBar(text: self.$promptText, placeholder: "Describe what you want...", onSearchButtonClicked: {
                    print(self.promptText)
                })
                Divider()
                    .frame(height: 20)
                Button {
                    if (self.promptText != "") {
                        self.items.append(EditorGenAiObject.generate(prompt: self.promptText))
                    }
                } label: {
                    Image(systemName: "paperplane")
                }
                .padding(.trailing, 20)
            }
            
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(), count: 4),
                    spacing: 50
                ) {
                    ForEach (items) { item in
                        Button {
                            if let entity = item.asEntity() {
                                appModel.editorEntities.append(entity)
                            }
                        } label: {
                            GenAIItemBlock(item: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct PresetItemBlock: View {
    var item: EditorLibraryObject
    
    var body: some View {
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
}

struct GenAIItemBlock: View {
    @ObservedObject var item: EditorGenAiObject
    
    var body: some View {
        VStack {
            if (item.url != nil) {
                Model3D(url: item.url!) { model in
                    model
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 200, height: 200)
            } else {
                ProgressView()
                    .frame(width: 200, height: 200)
            }
            
            
            Text(item.name)
                .font(.headline)
                .padding(.top, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
