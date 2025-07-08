//
//  ContentView.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-07-04.
//

import SwiftUI

struct ContentView: View {
    @State private var currentProblem = generateProblem(difficulty: 11, op: .add)
    @State private var userInput = ""
    @State private var history: [(problem: MathProblem, correct: Bool)] = [] // true = correct, false = wrong
    @State private var selectedOperator: Operator = .add
    @State private var difficulty: Double = 11
    @State private var showHighScores = false
    @State private var currentStreak = 0
    
    @StateObject private var highScores = HighScores()
    
    let numberOfTasks = 5
    let minDifficulty: Double = 6
    let maxDifficulty: Double = 35

var body: some View {
    GeometryReader { geometry in
        VStack(spacing: 9) {
            // Top Row: Logo and Menu
            ZStack {
                Text("Mathulator")
                    .font(.headline)
                    .padding(3)
                    .background(Color.black.opacity(0.2))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))

                HStack {
                    Spacer()
                    Button(action: {
                        showHighScores = true
                    }) {
                        Text("\u{1F3C6}")
                            .font(.headline)
                            .frame(maxWidth: geometry.size.width * 0.12, maxHeight: geometry.size.height * 0.06)
                            .background(Color.black.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding(.trailing, 12)
                    }
                }
            }
            .frame(height: geometry.size.height * 0.06)
            
//            HStack {
//                Spacer()
//                Text("Mathulator")
//                    .font(.headline)
//                    .padding(3)
//                    .background(Color.black.opacity(0.2))
//                    .foregroundColor(.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                Spacer()
//                Button(action: {
//                    userInput = String(userInput.dropLast())
//                }) {
//                    Text("...")                    // Placeholder for high scores
//                        .font(.headline)
////                        .padding()
//                        .frame(maxWidth: geometry.size.width * 0.10)//, maxHeight: geometry.size.height * 0.03)
//                        .background(Color.black.opacity(0.2))
//                        .clipShape(RoundedRectangle(cornerRadius: 5))
//                }
//            }
//            .frame(height: geometry.size.height * 0.03)

            //History
            VStack {
                HStack{
                    let symbols = history.map { $0.correct ? "checkmark.circle.fill" : "xmark.circle.fill" }
                    let maxSymbols = 20
                    let filledSymbols = Array(symbols.suffix(maxSymbols))
                    let paddedSymbols = filledSymbols + Array(repeating: "questionmark.circle.fill", count: maxSymbols - filledSymbols.count)

                    VStack(spacing: 4) {
                        ForEach(0..<2, id: \.self) { row in
                            HStack(spacing: 4) {
                                ForEach(0..<10, id: \.self) { col in
                                    let index = row * 10 + col
                                    Image(systemName: paddedSymbols[index])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(
                                            paddedSymbols[index] == "checkmark.circle.fill" ? .green :
                                            paddedSymbols[index] == "xmark.circle.fill" ? .red : .gray
                                        )
                                }.animation(.easeInOut, value: history.count)
                            }
                        }
                    }
                    Text("\(scorePercentage())%")
                        .frame(width: geometry.size.height * 0.15, height: geometry.size.height * 0.08)  // WIP
                        .font(.title2)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: geometry.size.height * 0.15, height: geometry.size.height * 0.10)  // WIP
                    
                }
                HStack {
                    if let last = history.last {
                        Image(systemName: last.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(last.correct ? .green : .red)
                    } else {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.gray)
                    }

                    Text(history.last.map {
                        "\($0.problem.num1) \($0.problem.symbol) \($0.problem.num2) = \($0.problem.answer)"
                    } ?? "")
                    .frame(maxWidth: .infinity, minHeight: 25, alignment: .leading)
                    .padding(.leading, 15)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                // Last problem show at the bottom of this section
            }  .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.12)
                        .padding()
                        .background(Color.white.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

            
            // Problem Display
            VStack {
                Text("\(currentProblem.num1) \(currentProblem.symbol) \(currentProblem.num2) =")
                    .font(.largeTitle)
                    .padding(4)
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.10)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                // Removed spacer, added clipShape
            
                HStack(spacing: 10) {  // Added spacing
                    Text(userInput.isEmpty ? "?" : userInput)
                        .font(.title)
                        .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.05)
//                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Button(action: {
                        userInput = String(userInput.dropLast())
                    }) {
                        Text("\u{232B}") // Unicode symbol for backspace (U+232B)
                            .font(.title)
                            .frame(maxWidth: geometry.size.width * 0.15, maxHeight: geometry.size.height * 0.05)
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
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
                    Button("\u{23CE}") {  // unicode for carrige return
                        submitAnswer()
                    }
                    .font(.title2)
                    .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.075)
                    .background(Color.white .opacity(0.4))
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
            .background(Color.orange)
            .frame(height: geometry.size.height * 0.36)
            .clipShape(RoundedRectangle(cornerRadius: 15))  //
//            .cornerRadius(10)

            // Difficulty Slider
            HStack {
                Slider(value: $difficulty, in: minDifficulty...maxDifficulty, step: 1)
                    .accentColor(.green)
                    .frame(height: geometry.size.height * 0.04) // shorter height
                Text("\(Int(difficulty))")
                    .font(.caption)
                    .frame(minWidth: geometry.size.width * 0.05)
                    .padding(6)
                    .background(Color(hue: (difficulty - minDifficulty) / (maxDifficulty - minDifficulty), saturation: 0.8, brightness: 1.0))
                    .animation(.easeInOut(duration: 0.3), value: difficulty)
//                    .background(Color.white) // booring!
                    .cornerRadius(10)
                    .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )            }
            .padding(.horizontal)
            .frame(height: geometry.size.height * 0.03)

            // Operator Selection
            HStack {
                ForEach(Operator.allCases, id: \.self) { op in
                    Button(op.rawValue) {
                        highScores.updateIfHigher(streak: currentStreak, difficulty: Int(difficulty), op: selectedOperator)
                        currentStreak = 0
                        selectedOperator = op
                        newProblem()
                        history.removeAll()
                    }
                    .frame(width: geometry.size.width * 0.22, height: geometry.size.height * 0.08)
                    .font(.title)
                    .background(op == selectedOperator ? Color.white.opacity(0.4) : Color.black.opacity(0.4))
                    .foregroundColor(op == selectedOperator ? Color.black : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
//            .padding(.top)
            .frame(height: geometry.size.height * 0.12)
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .background(Color.blue)
        .onAppear {
            newProblem()
        }
        .onChange(of: difficulty) { _ in
            highScores.updateIfHigher(streak: currentStreak, difficulty: Int(difficulty), op: selectedOperator)
            currentStreak = 0
            newProblem()
            history.removeAll()
        }
        .sheet(isPresented: $showHighScores) {
            HighScoresView(highScores: highScores)
        }
    }
}

    struct HighScoresView: View {
        @ObservedObject var highScores: HighScores

        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(HighScores.difficulties, id: \.self) { difficulty in
                            HStack {
                                Text("Lv \(difficulty)")
                                    .frame(width: 50, alignment: .leading)
                                    .font(.caption)
                                
                                ForEach(Operator.allCases, id: \.self) { op in
                                    Text("\(highScores.highScore(for: difficulty, op: op))")
                                        .frame(maxWidth: .infinity)
                                        .font(.caption)
                                        .padding(4)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                }
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("High Scores")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
// Dummy which does compile and run, but shows nothing
//    struct HighScoresView: View {
//        var body: some View {
//            VStack(spacing: 20) {
//                Text("High Scores")
//                    .font(.largeTitle)
//                    .bold()
//                Text("Coming soon...")
//                    .foregroundColor(.gray)
//                Spacer()
//            }
//            .padding()
//        }
//    }
    
    // MARK: - Helpers

    func numButton(_ label: String, geometry: GeometryProxy) -> some View {
        Button(label) {
            userInput += label
        }
        .font(.title2)
        .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.08)
        .background(Color.black.opacity(0.4))
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    func submitAnswer() {
        guard let guess = Int(userInput) else { return }
        let correct = guess == currentProblem.answer
        history.append((currentProblem, correct))
        
        if correct {
                currentStreak += 1
            } else {
                highScores.updateIfHigher(streak: currentStreak, difficulty: Int(difficulty), op: selectedOperator)
                currentStreak = 0
            }

        userInput = ""
        newProblem()
    }

    func newProblem() {
        currentProblem = generateProblem(difficulty: difficulty, op: selectedOperator)
        userInput = ""
    }

    func scorePercentage() -> Int {
        guard !history.isEmpty else { return 0 }
        let correct = history.filter { $0.correct }.count
        return Int((Double(correct) / Double(history.count)) * 100)
    }

}
