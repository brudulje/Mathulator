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
    GeometryReader { geometry in
        VStack(spacing: 16) {
            // Top Row: Logo and Menu
            HStack {
                Spacer()
                Text("Matteboka")
                    .font(.title3)
                    .padding(3)
                    .background(Color.black.opacity(0.2))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Spacer()
//                Button("=") {
//                    // Placeholder for settings or menu
//                }
//                .font(.title)
//                .padding()
//                .background(Color.green)
//                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .frame(height: geometry.size.height * 0.04)

            // History + Score
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(history.suffix(5).enumerated()), id: \.offset) { index, entry in
                        let problem = entry.problem
                        let success = entry.correct
                        HStack {
                            Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(success ? .green : .red)
                            Text("\(problem.num1) \(problem.symbol) \(problem.num2) = \(problem.answer)")
                                .frame(maxWidth: .infinity, minHeight: 14, maxHeight: geometry.size.height * 0.03, alignment: .leading)
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
                        .font(.title2)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: geometry.size.height * 0.08)
                    Button("Null") {
                        history.removeAll()
                    }
                    .padding(.top, 10)
                }
            }
            .frame(height: geometry.size.height * 0.12)
            .padding()
            .background(Color.gray)

            // Problem Display
            VStack {
                Text("\(currentProblem.num1) \(currentProblem.symbol) \(currentProblem.num2) =")
                    .font(.largeTitle)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.1 )
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Button(action: {
                    userInput = ""
                }) {
                    Text(userInput.isEmpty ? "?" : userInput)
//                        .font(userInput.count > 6 ? .caption : (userInput.count > 4 ? .title2 : .largeTitle))
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20))
               
            }
            .padding(.horizontal)
            .frame(height: geometry.size.height * 0.15)

            // Numpad
            VStack(spacing: 3) {
                ForEach([[7,8,9],[4,5,6],[1,2,3]], id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(row, id: \.self) { num in
                            numButton(String(num), geometry: geometry)
                        }
                    }
                }

                HStack(spacing: 10) {
                    numButton("-", geometry: geometry)
                    numButton("0", geometry: geometry)
                    Button("Svar") {
                        submitAnswer()
                    }
                    .font(.title2)
                    .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.07)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            .padding()
            .background(Color.gray)
            .frame(height: geometry.size.height * 0.32)

            // Difficulty Slider
            HStack {
                Slider(value: $difficulty, in: 6...36, step: 1)
                    .accentColor(.green)
                    .frame(height: geometry.size.height * 0.04) // shorter height
                Text("\(Int(difficulty))")
                    .font(.caption)
                    .frame(minWidth: geometry.size.width * 0.05)
                    .padding(6)
                    .background(Color(hue: (difficulty - 6) / 30, saturation: 0.8, brightness: 1.0))
                    .animation(.easeInOut(duration: 0.3), value: difficulty)
//                    .background(Color.white) // booring!
                    .cornerRadius(10)
                    .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )            }
            .padding(.horizontal)
            .frame(height: geometry.size.height * 0.04)

            // Operator Selection
            HStack {
                ForEach(Operator.allCases, id: \.self) { op in
                    Button(op.rawValue) {
                        selectedOperator = op
                        newProblem()
                    }
                    .frame(width: geometry.size.width * 0.22, height: geometry.size.height * 0.08)
                    .font(.title)
                    .background(op == selectedOperator ? Color.white.opacity(0.4) : Color.black.opacity(0.4))
                    .foregroundColor(op == selectedOperator ? Color.black : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.top)
            .frame(height: geometry.size.height * 0.08)
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .background(Color.blue)
//        .ignoresSafeArea(.all)
//        .ignoresSafeArea(.container, edges: [.top, .bottom])
//        .ignoresSafeArea(.container, edges: .top)
    }
}

    // MARK: - Helpers

    func numButton(_ label: String, geometry: GeometryProxy) -> some View {
        Button(label) {
            userInput += label
        }
        .font(.title2)
        .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.06)
        .background(Color.black.opacity(0.8))
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
