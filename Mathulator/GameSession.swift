//
//  GameSession.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-11-03.
//

import Foundation

final class GameSession: ObservableObject {
//    let mode: GameMode
    let highScores: HighScores   // or whatever type you already use
    
    init(mode: GameMode, startDifficulty: Double, selectedOperator: Operator, highScores: HighScores) {
        self.mode = mode
        self.difficulty = startDifficulty
        self.selectedOperator = selectedOperator
        self.highScores = highScores
        self.currentProblem = generateProblem(difficulty: startDifficulty, op: selectedOperator)
//        print("GameSession is now in mode: \(mode)")
    }
    
    // Core state shared between modes
    @Published var mode: GameMode
    @Published var currentProblem: MathProblem // = generateProblem(difficulty: 11, op: .add)
    @Published var userInput = ""
    @Published var history: [(problem: MathProblem, correct: Bool, guess: Int)] = []
    @Published var selectedOperator: Operator = .add
    @Published var difficulty: Double
    @Published var currentStreak = 0
    @Published var problemCount: Int = 0
    @Published var crescendoProblemsPerDifficulty = 3
    @Published var passFailMarkList: [Bool] = []
    
}

extension GameSession {
    func submitAnswer() {  // This is the function all modes should run.
//        print("Got new input: \(userInput)")
        guard let guess = Int(userInput) else { return }
        let isCorrect = GameLogic.checkAnswer(guess, for: currentProblem)
        history.append((currentProblem, isCorrect, guess))
        
//        print("Got answer: \(guess), in mode: \(mode)")
        switch mode {
        case .normal:
            passFailMarkList.append(isCorrect)
//            print("in normal mode")
            if isCorrect {
                currentStreak += 1
            } else {
                currentStreak = 0
            }
            highScores.updateIfHigher(
                streak: currentStreak,
                difficulty: Int(difficulty),
                op: selectedOperator
            )
            
        case .crescendo:
//            print("in crescendo mode")
            problemCount += 1
            if isCorrect {
                currentStreak += 1
                if problemCount.isMultiple(of: crescendoProblemsPerDifficulty) {
                    passFailMarkList.append(isCorrect)
                    difficulty += 1 // Crescendo magic
                    currentStreak = 0
//                    history.removeAll()
                }
            } else {
//                difficulty = max(difficulty - 1, DifficultyConfig.minDifficulty)
                // Stop crescendo mode
            }
            // FIXME: Update crescendo score list
        }
        
        // Whatever the mode is, create a new problem
        userInput = ""
        newProblem()
    }
    
    func newProblem() {
        //        print("Current problem was: \(currentProblem). We're now in mode: \(mode)")
        //        print("Generating new problem")
        currentProblem = generateProblem(difficulty: difficulty, op: selectedOperator)
//        print("Created problem: \(currentProblem) in mode: \(mode)")
    }
    
    func handleOperatorChange(_ newOperator: Operator) {
        // Update high scores before resetting
        highScores.updateIfHigher(
            streak: currentStreak,
            difficulty: Int(difficulty),
            op: selectedOperator
        )
        
        // Reset state
        currentStreak = 0
        selectedOperator = newOperator
        history.removeAll()
        
        // Generate a new problem for the selected operator
        newProblem()
    }
    
        func startCrescendo(with op: Operator) {
            mode = .crescendo
            selectedOperator = op
            difficulty = DifficultyConfig.minDifficulty
            history.removeAll()
            userInput = ""
            currentProblem = generateProblem(difficulty: difficulty, op: op)
        }
    
}
