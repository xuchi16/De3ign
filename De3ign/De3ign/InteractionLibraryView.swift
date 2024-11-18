//
//  InteractionLibraryView.swift
//  De3ign
//
//  Created by Lemocuber on 2024/11/7.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct InteractionLibraryView: View {
    
    @Environment(\.dismiss) var dismiss
    let appModel: AppModel
    
    let selectedModel: LibraryModel
    @State var items: [LibraryInteraction] = [
        .init(.none),
        .init(.disappear),
        .init(.zoom),
        .init(.chat),
        .init(.song)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Select a Interaction for \(selectedModel.name)")
                    .font(.title2)
                    .padding()
                
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(), count: 4),
                        spacing: 50
                    ) {
                        ForEach(items) { item in
                            Button(action: {
                                let entity = selectedModel.asEntity(interaction: .init(item))
                                appModel.libraryEntities.append(entity)
                                dismiss()
                            }) {
                                VStack {
                                    Image(item.iconName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 200, height: 200)
                                    Text(item.name)
                                        .font(.headline)
                                        .padding(.top, 10)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle()) // Remove default button style
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Apply Interaction")
    }
}
