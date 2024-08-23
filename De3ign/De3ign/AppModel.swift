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
            DSpace(name: "jovita", volumeName: jovitaVolume),
            DSpace(name: "basketball", volumeName: basketballVolume),
            DSpace(name: "superbrain", volumeName: superBrainVolume),
            DSpace(name: "temple", volumeName: templeVolume)
        ]
    }
}
