//
//  MathGenerator.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-07-04.
//

import Foundation

struct MathProblem {
    let num1: Int
    let num2: Int
    let answer: Int
    let symbol: String
}

enum Operator: String, CaseIterable {
    case add = "+"
    case sub = "-"
    case mult = "×"
    case div = "÷"
}

func interval(for difficulty: Double) -> (Int, Int) {
    /// Return interval based on difficulty for generateProblem to pick numbers from 
    let lower = max(1, Int(pow(10, difficulty / 10 - 0.5)))
    let upper = Int(pow(10, difficulty / 10))
    return (lower, upper)
}

func generateProblem(difficulty: Double, op: Operator) -> MathProblem {
//    let (lower, upper) = interval(for: difficulty)
    let x: Int
    let y: Int
    let answer: Int
    
    switch op {
    case .add:
        let (lower, upper) = interval(for: difficulty)
        x = Int.random(in: lower...upper)
        y = Int.random(in: lower...upper)
        answer = x + y
    case .sub:
        let (lower, upper) = interval(for: difficulty)
        x = Int.random(in: lower...upper)
        y = Int.random(in: lower...upper)
        answer = x - y
    case .mult:
        let (lower, upper) = interval(for: 0.8 * difficulty)
        x = Int.random(in: lower...upper)
        y = Int.random(in: lower...upper)
        answer = x * y
    case .div:
        let (lower, _) = interval(for: difficulty)
        let (_, upper) = interval(for: 1.5 * difficulty)
        y = Int.random(in: 2...Int(difficulty))
        let quotient = Int.random(in: lower...upper / max(y, 1))
        x = quotient * y
        answer = quotient
    }
    
    return MathProblem(num1: x, num2: y, answer: answer, symbol: op.rawValue)
}
