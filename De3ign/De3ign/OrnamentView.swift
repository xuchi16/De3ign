//
//  OrnamentView.swift
//  De3ign
//
//  Created by xuchi on 2024/8/23.
//

import SwiftUI

struct OrnamentView: View {
    
    var spaceId: String
    var body: some View {
        HStack {
            ToggleImmersiveSpaceButton(name: spaceId)
        }
        .glassBackgroundEffect()
    }
}
