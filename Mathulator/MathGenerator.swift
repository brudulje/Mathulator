//
//  MathGenerator.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-07-04.
//

import Foundation

struct MathProblem: Equatable {
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

private var previousProblem: MathProblem? = nil

func generateProblem(difficulty: Double, op: Operator) -> MathProblem {
//    let (lower, upper) = interval(for: difficulty)
    var x: Int
    var y: Int
    var z: Int
    var w: Int
    var v: Int
    var answer: Int
    
    var thisProblem: MathProblem? = nil
    
    repeat {  // Make sure two consecutive problems are different
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
            let (_, upper) = interval(for: 1.3 * difficulty)
            z = Int.random(in: lower...upper)
            w = Int.random(in: 2...Int(difficulty))
            v = max(z, w)
            y = min(z, w)
            answer = v / max(y, 1)
            x = answer * y
            //        print("interval", lower, upper, "numbers", z, w, "sorted", v, y, "done", x, answer)
        }
        thisProblem = MathProblem(num1: x, num2: y, answer: answer, symbol: op.rawValue)
//        print("This \(thisProblem) \nPrev \(previousProblem)\n")
    } while thisProblem == previousProblem
    previousProblem = thisProblem
//    print("Generated problem: \(x) \(op.rawValue) \(y) = \(answer) at difficulty \(difficulty)")
    return thisProblem!
}
