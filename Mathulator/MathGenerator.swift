//
//  MathGenerator.swift
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
    case mult = "×"
    case add = "+"
    case sub = "-"
    case div = "÷"
}

func interval(for difficulty: Double) -> (Int, Int) {
    let lower = max(1, Int(pow(10, difficulty / 10 - 0.5)))
    let upper = Int(pow(10, difficulty / 10))
    return (lower, upper)
}

func generateProblem(difficulty: Double, op: Operator) -> MathProblem {
    let (lower, upper) = interval(for: difficulty)
    let x: Int
    let y: Int
    let answer: Int

    switch op {
    case .mult:
        x = Int.random(in: lower...upper)
        y = Int.random(in: lower...upper)
        answer = x * y
    case .add:
        x = Int.random(in: lower...upper)
        y = Int.random(in: lower...upper)
        answer = x + y
    case .sub:
        x = Int.random(in: lower...upper)
        y = Int.random(in: lower...upper)
        answer = x - y
    case .div:
        let xUpper = interval(for: 1.8 * difficulty).1
        y = Int.random(in: 2...Int(difficulty))
        let quotient = Int.random(in: lower...xUpper / max(y, 1))
        x = quotient * y
        answer = quotient
    }

    return MathProblem(num1: x, num2: y, answer: answer, symbol: op.rawValue)
}
