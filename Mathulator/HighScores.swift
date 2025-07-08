//
//  HighScores.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-07-08.
//


import Foundation

class HighScores: ObservableObject {
    static let difficulties = Array(6...35)
    static let operatorCount = Operator.allCases.count
    
    @Published var matrix: [[Int]]
    
    init() {
        self.matrix = Array(repeating: Array(repeating: 0, count: HighScores.operatorCount), count: HighScores.difficulties.count)
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
}