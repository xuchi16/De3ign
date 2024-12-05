//
//  Util.swift
//  De3ign
//
//  Created by Lemocuber on 2024/11/26.
//

import Foundation

let jsonE = JSONEncoder()
let jsonD = JSONDecoder()

extension String {
    func sanitized() -> String {
        let pattern = "[^\\p{L}\\p{N}]"
        let replaced = self.replacingOccurrences(of: pattern, with: "_", options: .regularExpression)
        let compressed = replaced.replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
        return compressed.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }
}
