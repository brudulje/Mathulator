//
//  HighScores.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-07-08.
//


import Foundation

class HighScores: ObservableObject {
    //    static let difficulties = Array(6...35)
    static let minDifficulty = ContentView.minDifficulty
    static let maxDifficulty = ContentView.maxDifficulty
    static let difficulties = Array(Int(minDifficulty)...Int(maxDifficulty))
    static let operatorCount = Operator.allCases.count
    
    private static let storageKey = "highScoreMatrix"
    
    @Published var matrix: [[Int]] {
        didSet {
            save()
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode([[Int]].self, from: data) {
            self.matrix = decoded
        } else {
            self.matrix = Array(repeating: Array(repeating: 0, count: Self.operatorCount), count: Self.difficulties.count)
        }
    }
    func updateIfHigher(streak: Int, difficulty: Int, op: Operator) {
        guard let row = HighScores.difficulties.firstIndex(of: difficulty),
              let col = Operator.allCases.firstIndex(of: op)
        else { return }
        
        if streak > matrix[row][col] {
            matrix[row][col] = streak
        }
    }
    
    func highScore(for difficulty: Int, op: Operator) -> Int {
        guard let row = HighScores.difficulties.firstIndex(of: difficulty),
              let col = Operator.allCases.firstIndex(of: op)
        else { return 0 }
        
        return matrix[row][col]
    }
    private func save() {
        if let encoded = try? JSONEncoder().encode(matrix) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
        }
    }
}
