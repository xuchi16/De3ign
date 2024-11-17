//
//  LibraryInteraction.swift
//  De3ign
//
//  Created by Lemocuber on 2024/11/7.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct PredefinedGestures {
    var tap: ((EntityTargetValue<TapGesture.Value>) -> Void)?
}

let availableInteractions: Dictionary<InteractionName, PredefinedGestures> = [
    .none: .init(),
    .disappear: .init{ event in
        event.entity.isEnabled = !event.entity.isEnabled
    },
    .zoom: {
        var cnt = 1
        return .init { event in
            print(cnt)
            if (cnt % 15 == 0) {
                event.entity.progenitor?.scale /= 5
            }
            event.entity.progenitor?.scale *= 1.1
            cnt += 1
        }
    }(),
    .chat: {
        var chatter = Chatter()
        return .init { event in
            if (!chatter.isRecording) {
                event.entity.progenitor?.scale *= 1.25
                Task { @MainActor in
                    chatter.startRecognition()
                }
            } else {
                event.entity.progenitor?.scale *= 0.8
                Task { @MainActor in
                    if let name = event.entity.progenitor?.name {
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

struct LibraryInteraction: Identifiable {
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

struct InteractionComponent: Component {
    let name: String
    let gesture: PredefinedGestures
    
    init(_ libraryInteraction: LibraryInteraction) {
        self.name = libraryInteraction.name
        self.gesture = availableInteractions[libraryInteraction.interactionName]!
    }
}
