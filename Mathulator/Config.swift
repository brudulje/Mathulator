//
//  Config.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-07-09.
//


struct DifficultyConfig {
    static let minDifficulty: Double = 6
    static let maxDifficulty: Double = 30
    static var difficulties: [Int] {
        Array(Int(minDifficulty)...Int(maxDifficulty))
    }
}
