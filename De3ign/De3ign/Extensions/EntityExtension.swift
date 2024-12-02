//
//  EntityExtension.swift
//  De3ign
//
//  Created by xuchi on 2024/12/2.
//

import SwiftUI
import RealityKit
import RealityKitContent

extension Entity {
    func toBaseData() -> EntityBaseData? {
        // workaround(?) didn't manage to create a type or something; so just hardcode
        if let metadata = self.metadata {
            switch metadata.source {
                
            case .library(let model):
                return [
                    "type": "library",
                    "name": model.name,
                    "resourceName": model.resourceName,
                    "transform": try! String(data: jsonE.encode(self.transform), encoding: .utf8)!
                ]
            case .genAi(let model):
                return [
                    "type": "genAi",
                    "name": model.name,
                    "fileName": model.url!.lastPathComponent,
                    "transform": try! String(data: jsonE.encode(self.transform), encoding: .utf8)!
                ]
            }
            
//            let data = try! JSONSerialization.data(withJSONObject: json)
//
//            let url = getSaveDirectory().appendingPathComponent("1.txt")
//            try! data.write(to: url)
//            print(url)
        }
        return nil
    }
    
    // i know this is ugly but hopefully it runs anyway?
    static func fromBaseData(data: EntityBaseData) -> Entity? {
        if let type = data["type"] {
            var entity: Entity
            
            if (type == "library") {
                entity = LibraryModel(
                    name: data["name"]!,
                    resourceName: data["resourceName"]!
                ).asEntity()!
            }
            else if (type == "genAi") {
                entity = GenAIModel(
                    name: data["name"]!,
                    url: getGenAiModelsDirectory().appendingPathComponent(data["fileName"]!)
                ).asEntity()!
            }
            else {
                return nil
            }
            
            entity.transform = try! jsonD.decode(Transform.self, from: Data(data["transform"]!.utf8))
            
            return entity
        }
        return nil
    }
}
