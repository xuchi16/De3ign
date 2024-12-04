//
//  LibraryInteraction.swift
//  De3ign
//
//  Created by Lemocuber on 2024/11/7.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct EditorPredefinedGesture {
    var tap: ((EntityTargetValue<TapGesture.Value>) -> Void)?
}

let availableInteractions: Dictionary<InteractionName, EditorPredefinedGesture> = [
    .none: .init(),
    .disappear: .init{ event in
        event.entity.isEnabled = !event.entity.isEnabled
    },
    .zoom: {
        var cnt = 1
        return .init { event in
            if (cnt % 15 == 0) {
                event.entity.editorProgenitor?.scale /= 5
            }
            event.entity.editorProgenitor?.scale *= 1.1
            cnt += 1
        }
    }(),
    .chat: {
        var chatter = Chatter()
        return .init { event in
            if (!chatter.isRecording) {
                event.entity.editorProgenitor?.scale *= 1.25
                Task { @MainActor in
                    chatter.startRecognition()
                }
            } else {
                event.entity.editorProgenitor?.scale *= 0.8
                Task { @MainActor in
                    if let name = event.entity.editorProgenitor?.name {
                        chatter.personality = name
                    }
                    chatter.endRecognition()
                }
            }
        }
    }(),
    .song: {
        var song = Song(name: "senpai")
        return .init { _ in
            song.toggle()
        }
    }()
]

struct EditorInteraction: Identifiable {
    let id = UUID()
    let interactionName: InteractionName
    let iconName: String
    let name: String
    
    init(_ interactionName: InteractionName) {
        self.interactionName = interactionName
        self.name = interactionName.rawValue
        self.iconName = "icon_\(name.lowercased())"
    }
}

struct EditorInteractionComponent: Component {
    let name: String
    let gesture: EditorPredefinedGesture
    
    init(_ libraryInteraction: EditorInteraction) {
        self.name = libraryInteraction.name
        self.gesture = availableInteractions[libraryInteraction.interactionName]!
    }
}

