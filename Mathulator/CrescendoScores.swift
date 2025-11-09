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
    
    @Published var matrix: [Int] {
        didSet {
            save()
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode([Int].self, from: data) {
            self.matrix = decoded
        } else {
            self.matrix = Array(repeating: 0, count: Self.operatorCount)
//            , count: Self.difficulties.count)
        }
    }
    
    func reset(op: Operator) {
        guard let row = Operator.allCases.firstIndex(of: op)
        else { return }
        
        matrix[row] = 0
    }
    
    func updateIfHigher(difficulty: Int, op: Operator) {
        guard let row = Operator.allCases.firstIndex(of: op)
        else { return }
        
        if difficulty > matrix[row] {
            matrix[row] = difficulty
        }
    }
    
    func crescendoScore( op: Operator) -> Int {
        guard let row = Operator.allCases.firstIndex(of: op)
        else { return 0 }
        
        return matrix[row]
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(matrix) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
        }
    }
}
