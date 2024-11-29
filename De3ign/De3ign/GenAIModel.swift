//
//  ModelGenerator.swift
//  De3ign
//
//  Created by Lemocuber on 2024/11/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

class GenAIModel: ObservableObject, Identifiable, SceneUsable {
    let id = UUID()
    let name: String
    @Published var url: URL? = nil
    
    init(name: String, url: URL? = nil) {
        self.name = name
        self.url = url
    }
    
    func asEntity() -> Entity? {
        if self.url == nil {
            return nil
        }
        let entity = try! Entity.load(contentsOf: self.url!)
        entity.name = self.name
        entity.position = [0,0,0]
        entity.scale *= 0.2
        entity.components.set(MetadataComponent(id: self.id, name: self.name, source: .genAi(self)))
        entity.components.set(HoverEffectComponent())
        entity.components.set(InputTargetComponent())
        entity.generateCollisionShapes(recursive: true)
        return entity
    }
    
    static func listModels() -> [GenAIModel] {
        let fileManager = FileManager.default
        let modelsDirectory = getGenAiModelsDirectory()
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: modelsDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return fileURLs.map { fileURL in
                let fileName = fileURL.lastPathComponent
                let name = fileName.components(separatedBy: "@").first ?? fileName
                return .init(name: name, url: fileURL)
            }
        } catch {
            print("Error listing models: \(error)")
            return []
        }
    }
    
    static func generate(prompt: String) -> GenAIModel {
        let model = GenAIModel(name: prompt)
        
        Task {
            do {
                let jobId = try await startJob(prompt: prompt)
                print("Job started with ID: \(jobId)")
                
                let outputPath = try await pollJobStatus(jobId: jobId)
                print("Job finished! Output available at: \(outputPath)")
                
                let localFileURL = try await downloadOutput(from: outputPath, name: prompt.sanitized())
                print("File downloaded to: \(localFileURL.path)")
                
                DispatchQueue.main.async {
                    model.url = localFileURL
                }
            } catch {
                print("Error: \(error)")
            }
        }
        
        return model
    }
}

private let baseURL = "http://124.222.130.161:19991"
private let authToken = "LLL"
private let modelsDirectoryName = "AIModels"

func getGenAiModelsDirectory() -> URL {
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let modelsDirectory = documentsDirectory.appendingPathComponent(modelsDirectoryName)
    
    if !fileManager.fileExists(atPath: modelsDirectory.path) {
        try? fileManager.createDirectory(at: modelsDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    return modelsDirectory
}

private struct JobResponse: Decodable {
    let jobId: String
}

private struct StatusResponse: Decodable {
    let isFinished: Bool
    let outputPath: String?
}

private func startJob(prompt: String) async throws -> String {
    guard let url = URL(string: "\(baseURL)/generate") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(authToken, forHTTPHeaderField: "auth")
    
    let body: [String: String] = ["prompt": prompt]
    request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    
    let (data, _) = try await URLSession.shared.data(for: request)
    let jobResponse = try JSONDecoder().decode(JobResponse.self, from: data)
    return jobResponse.jobId
}

private func pollJobStatus(jobId: String) async throws -> String {
    guard let url = URL(string: "\(baseURL)/status/\(jobId)") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.addValue(authToken, forHTTPHeaderField: "auth")
    
    while true {
        let (data, _) = try await URLSession.shared.data(for: request)
        let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
        
        if statusResponse.isFinished {
            guard let outputPath = statusResponse.outputPath else {
                throw NSError(domain: "JobError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Job finished but outputPath is missing."])
            }
            return outputPath
        }
        
        // short poll, interval 10s
        try await Task.sleep(nanoseconds: 10_000_000_000)
    }
}

private func downloadOutput(from outputPath: String, name: String) async throws -> URL {
    let fullURLString = "\(baseURL)\(outputPath)"
    guard let url = URL(string: fullURLString) else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.addValue(authToken, forHTTPHeaderField: "auth")
    
    let originalFileName = url.lastPathComponent
    let saveFileName = "\(name)@\(originalFileName)"
    
    let (tempURL, _) = try await URLSession.shared.download(for: request)
    let fileManager = FileManager.default
    let destinationDirectory = getGenAiModelsDirectory()
    let destinationURL = destinationDirectory.appendingPathComponent(saveFileName)
    
    if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
    }
    try fileManager.moveItem(at: tempURL, to: destinationURL)
    return destinationURL
}
