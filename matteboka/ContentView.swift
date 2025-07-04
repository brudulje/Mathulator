//
//  ContentView.swift
//  matteboka
//
//  Created by Joachim Seland Graff on 2025-07-04.
//

import SwiftUI

struct ContentView: View {
    @State private var currentProblem = MathProblem(num1: 3, num2: 4, answer: 7, symbol: "+")
    @State private var userInput = ""
    @State private var history: [(problem: MathProblem, correct: Bool)] = [] // true = correct, false = wrong
    @State private var selectedOperator: Operator = .add
    @State private var difficulty: Double = 11

    let numberOfTasks = 5

    var body: some View {
        VStack(spacing: 10) {
            // Top Row: Logo and Menu
            HStack {
                Spacer()
                Text("Matteboka")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                Spacer()
                Button("=") {
                    // Placeholder for settings or menu
                }
                .font(.title)
                .padding()
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }

            // History + Score
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(history.suffix(5).enumerated()), id: \.offset) { index, entry in
                        let problem = entry.problem
                        let success = entry.correct
                        HStack {
                            Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(success ? .green : .red)
                            Text("\(problem.num1) \(problem.symbol) \(problem.num2) = \(problem.answer)")
                                .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 35, alignment: .leading)
                                .padding(.leading, 5)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                Spacer()
                VStack {
                    Text("\(scorePercentage())%")
                        .font(.title)
                        .padding()
                        .background(Color.cyan)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Button("Null") {
                        history.removeAll()
                    }
                    .padding(.top, 10)
                }
            }
            .frame(height: 200)
            .padding()
            .background(Color.gray)

            // Problem Display
            HStack {
                Text("\(currentProblem.num1) \(currentProblem.symbol) \(currentProblem.num2) =")
                    .font(.largeTitle)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Button(action: {
                    userInput = ""
                }) {
                    Text(userInput.isEmpty ? "?" : userInput)
                        .font(userInput.count > 6 ? .caption : (userInput.count > 4 ? .title2 : .largeTitle))
                        .padding()
                        .frame(width: 120)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(.horizontal)

            // Numpad
            VStack(spacing: 3) {
                ForEach([[7,8,9],[4,5,6],[1,2,3]], id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(row, id: \.self) { num in
                            numButton(String(num))
                        }
                    }
                }

                HStack(spacing: 10) {
                    numButton("-")
                    numButton("0")
                    Button("Svar") {
                        submitAnswer()
                    }
                    .font(.title2)
                    .frame(width: 80, height: 60)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            .padding()
            .background(Color.gray)

            // Difficulty Slider
            VStack {
                let sliderWidth: CGFloat = 260
                let minOffset: CGFloat = -130
                let xOffset = ((difficulty - 1) / 29) * sliderWidth + minOffset
                ZStack {
                    Slider(value: $difficulty, in: 6...36, step: 1)
                        .accentColor(.green)
                        .padding(.horizontal)
                    Text("\(Int(difficulty))")
                        .font(.caption)
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .background(Color.white)
                        .cornerRadius(10)
                        .offset(x: xOffset, y: -20)
                }
            }

            // Operator Selection
            HStack {
                ForEach(Operator.allCases, id: \.self) { op in
                    Button(op.rawValue) {
                        selectedOperator = op
                        newProblem()
                    }
                    .frame(width: 80, height: 60)
                    .font(.title)
                    .background(op == selectedOperator ? Color.purple : Color.pink)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.top)
        }
        .background(Color.cyan)
    }

    // MARK: - Helpers

    func numButton(_ label: String) -> some View {
        Button(label) {
            userInput += label
        }
        .font(.title2)
        .frame(width: 80, height: 50)
        .background(Color.gray.opacity(0.8))
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    func submitAnswer() {
        guard let guess = Int(userInput) else { return }
        let correct = guess == currentProblem.answer
        history.append((currentProblem, correct))
        if history.count > 5 { history.removeFirst() }
        userInput = ""
        newProblem()
    }

    func newProblem() {
        currentProblem = generateProblem(difficulty: difficulty, op: selectedOperator)
    }

    func scorePercentage() -> Int {
        guard !history.isEmpty else { return 0 }
        let correct = history.filter { $0.correct }.count
        return Int((Double(correct) / Double(history.count)) * 100)
    }
}
