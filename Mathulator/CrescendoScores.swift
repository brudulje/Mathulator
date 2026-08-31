//
//  CrescendoScores.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-11-09.
//

import Foundation

class CrescendoScores: ObservableObject {
    static let shared = CrescendoScores()
//    static let minDifficulty = DifficultyConfig.minDifficulty
//    static let maxDifficulty = DifficultyConfig.maxDifficulty
//    static let difficulties = Array(Int(minDifficulty)...Int(maxDifficulty))
    static let operatorCount = Operator.allCases.count
    
    private static let storageKey = "CrescendoScoreMatrix"
    
    @Published var matrix: [[Int]] {
        didSet { save() }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode([[Int]].self, from: data) {
            self.matrix = decoded
        } else {
            self.matrix = Array(repeating: Array(repeating: 0, count: Self.operatorCount), count: CrescendoLevel.allCases.count)
        }
    }
    
    func reset(level: CrescendoLevel, op: Operator) {
        guard let levelRow = CrescendoLevel.allCases.firstIndex(of: level),
              let opCol = Operator.allCases.firstIndex(of: op) else { return }
        matrix[levelRow][opCol] = 0
    }
    
    func updateIfHigher(level: CrescendoLevel, difficulty: Int, op: Operator) -> Bool {
        guard let levelRow = CrescendoLevel.allCases.firstIndex(of: level),
              let opCol = Operator.allCases.firstIndex(of: op) else { return false }
        if difficulty > matrix[levelRow][opCol] {
            matrix[levelRow][opCol] = difficulty
            return true  // let caller know that score was better than last highest
        } else {
            return false
        }
    }
    
    func crescendoScore(level: CrescendoLevel, op: Operator) -> Int {
        guard let levelRow = CrescendoLevel.allCases.firstIndex(of: level),
              let opCol = Operator.allCases.firstIndex(of: op) else { return 0 }
        return matrix[levelRow][opCol]
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(matrix) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
        }
    }
}
