//
//  AppModel.swift
//  De3ign
//
//  Created by xuchi on 2024/8/22.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    var selectedSpace: DSpace?
    var spaces: [DSpace] = []

    init() {
        spaces = [
            DSpace(id: "jovita", volumeName: jovitaVolume, name: "Jovita's Space", description: "呈现 Jovita 所喜爱的事物，探索下或许你能获得意想不到的感受"),
            DSpace(id: "basketball", volumeName: basketballVolume, name: "Basketball World", description: "篮球就是热血！这里不仅可以玩篮球，还能带你去真正的篮球世界"),
            DSpace(id: "superbrain", volumeName: superBrainVolume, name: "超脑 AI", description: "想了解我们在超脑 AI 的旅程吗？看过来！"),
            DSpace(id: "temple", volumeName: templeVolume, name: "Myth Zone", description: "这里你可以获得平静，平静和平静")
        ]
    }
}
