//
//  SaveLoad.swift
//  De3ign
//
//  Created by Lemocuber on 2024/11/28.
//

import SwiftUI
import RealityKit
import RealityKitContent

enum EntitySource {
    case library(EditorLibraryObject)
    case genAi(EditorGenAiObject)
}

typealias EntityBaseData = [String: String]

struct SavedRealm: Identifiable {
    let id = UUID()
    let name: String
    let dataList: [EntityBaseData]
}

func saveRealm(_ entityList: [Entity], name: String, appModel: AppModel) {
    var dataList: [EntityBaseData] = []
    
    for entity in entityList {
        if entity.isEnabled {
            if let data = entity.toBaseData() {
                dataList.append(data)
            }
        }
    }
    
    let destination = getSaveDirectory().appendingPathComponent("\(name.sanitized()).json")
    let json = try! JSONSerialization.data(withJSONObject: dataList)
    try! json.write(to: destination)
    
    // trigger update
    Task {
        try! await Task.sleep(nanoseconds: 500_000_000)
        await appModel.savedRealmsChangedCallback?()
    }
}

func loadRealm(_ realm: SavedRealm) -> [Entity] {
    var entityList: [Entity] = []
    for data in realm.dataList {
        if let entity = Entity.fromBaseData(data: data) {
            entityList.append(entity)
        }
    }
    return entityList
}

func listRealms() -> [SavedRealm] {
    let fileManager = FileManager.default
    let saveDirectory = getSaveDirectory()
    
    do {
        let fileURLs = try fileManager.contentsOfDirectory(at: saveDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        return try fileURLs.map { fileURL in
            let fileName = fileURL.lastPathComponent
            let name = fileName.components(separatedBy: ".").first ?? fileName
            
            let data = try jsonD.decode([EntityBaseData].self, from: Data(contentsOf: fileURL))
            return SavedRealm(name: name, dataList: data)
        }
    } catch {
        print("Error listing realms: \(error)")
        return [SavedRealm(name: "error", dataList: [])]
    }
}

private let saveDirectoryName = "Saves"

private func getSaveDirectory() -> URL {
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let saveDirectory = documentsDirectory.appendingPathComponent(saveDirectoryName)
    
    if !fileManager.fileExists(atPath: saveDirectory.path) {
        try? fileManager.createDirectory(at: saveDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    return saveDirectory
}
