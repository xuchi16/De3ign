//
//  libraryModel.swift
//  De3ign
//
//  Created by Lemocuber on 2024/10/11.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct LibraryModel: Identifiable {
    let id = UUID()
    let name: String
    let resourceName: String
    
    init(name: String, resourceName: String) {
        self.name = name
        self.resourceName = resourceName
    }
}

struct SceneLibraryModel {
    let name: String
    let entity: Entity
    let position: SIMD3<Float>
    
    init(_ libraryModel: LibraryModel) {
        self.name = libraryModel.name
        self.entity = try! Entity.load(named: libraryModel.resourceName, in: realityKitContentBundle)
        self.position = [0, 0, 0]
        self.entity.position = self.position
        self.entity.scale *= 0.1
    }
}
