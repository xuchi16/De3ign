//
//  KeypadView.swift
//  De3ign
//
//  Created by Lemocuber on 2024/12/2.
//

import SwiftUI

struct SafeKeypadView: View {
    @Binding var input: String

    private let gridItems = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private let keypadNumbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["*", "0", "#"]
    ]

    var body: some View {
        VStack {
            Text(">    \(input)")
                .font(.title2)
                .padding()

            LazyVGrid(columns: gridItems, spacing: 35) {
                ForEach(keypadNumbers, id: \.self) { row in
                    ForEach(row, id: \.self) { key in
                        Button(action: {
                            buttonTapped(key)
                        }) {
                            Text(key)
                                .font(.title)
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }.tint(.black)
                    }
                }
            }
        }
        .frame(width: 330)
        .padding()
    }

    private func buttonTapped(_ key: String) {
        switch key {
        case "*":
            input = ""
        case "#":
            if !input.isEmpty {
                input.removeLast()
            }
        default:
            input.append(key)
        }
    }
}
