//
//  KeypadView.swift
//  De3ign
//
//  Created by Lemocuber on 2024/12/2.
//

import SwiftUI

struct SafeKeypadView: View {
    @Binding var input: String
    let maxLength: Int
    let verify: (String) -> Bool
    var onInput: ((String) -> Void)? = nil

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
            Text(input + String(repeating: "*", count: maxLength - input.count))
                .font(.largeTitle)
                .fontDesign(.monospaced)
                .underline(true, color: .white)
                .padding(.horizontal, 35)
                .padding(.vertical, 20)
                .background(.black)
                .foregroundStyle(.white)
                .clipShape(.capsule)
                .padding(.bottom, 20)

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
                                .background(.black)
                                .clipShape(.circle)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(width: 330)
        .padding()
    }

    private func buttonTapped(_ key: String) {
        onInput?(key)
        switch key {
        case "*":
            input = ""
        case "#":
            let isCorrect = verify(input)
            if !isCorrect {
                clearBlinking()
            }
        default:
            if input.count < maxLength {
                input.append(key)
            }
        }
    }

    private func clearBlinking() {
        Task {
            for i in 1 ... 6 {
                if i % 2 != 0 {
                    input = String(repeating: "!", count: maxLength)
                } else {
                    input = ""
                }
                try! await Task.sleep(nanoseconds: 0_150_000_000)
            }
        }
    }
}
