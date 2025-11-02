//
//  GameLogic.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-11-03.
//

struct GameLogic {
    static func checkAnswer(_ userAnswer: Int, for problem: MathProblem) -> Bool {
        return userAnswer == problem.answer
    }
}
