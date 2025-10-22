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
    @State private var history: [(problem: MathProblem, correct: Bool, guess: Int)] = [] // true = correct, false = wrong
    @State private var selectedOperator: Operator = .add
    @State private var difficulty: Double = 11
    @State private var showHighScores = false
    @State private var currentStreak = 0
    @State private var showHighScoreDetail = false
    
    @StateObject private var highScores = HighScores()
    
    static let minDifficulty = DifficultyConfig.minDifficulty
    static let maxDifficulty = DifficultyConfig.maxDifficulty
    
    
    var body: some View {
        GeometryReader { geometry in
            let screenDiagonal = sqrt(geometry.size.width * geometry.size.width + geometry.size.height * geometry.size.height)
            VStack(spacing: 9) {
                // Top Row: Logo and High score
                ZStack {
                    // Logo
                    Text("Mathulator")
                        .responsiveFont(.headline)
                        .padding(3)
                        .background(Color.black.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    HStack {
                        Spacer()
                        // High score
                        Button(action: {
                            showHighScores = true
                        }) {
                            Text("\u{1F3C6}")  // Unicode Trophy
                                .responsiveFont(.headline)
                                .frame(maxWidth: geometry.size.width * 0.12, maxHeight: geometry.size.height * 0.06)
                                .background(Color.black.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .padding(.trailing, 12)
                        }
                    }
                }
                .frame(height: geometry.size.height * 0.06)
                
                
                //History
                VStack {
                    HStack{
                        let symbols = history.map { $0.correct ? "checkmark.circle.fill" : "xmark.circle.fill" }
                        let maxSymbols = 21
                        let filledSymbols = Array(symbols.suffix(maxSymbols))
                        let paddedSymbols = filledSymbols + Array(repeating: "questionmark.circle.fill", count: maxSymbols - filledSymbols.count)
                        // Show pass/fail for latest 20 problems attempted
                        VStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { row in
                                HStack(spacing: 4) {
                                    ForEach(0..<7, id: \.self) { col in
                                        let index = row * 7 + col
                                        Image(systemName: paddedSymbols[index])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: screenDiagonal * 0.022, height: screenDiagonal * 0.022)
                                            .foregroundColor(
                                                paddedSymbols[index] == "checkmark.circle.fill" ? .green :
                                                    paddedSymbols[index] == "xmark.circle.fill" ? .red.opacity(0.85) : .white.opacity(0.85)
                                            )
                                    }.animation(.easeInOut, value: history.count)
                                }
                            }
                        }
                        Button(action: {
                            showHighScoreDetail = true
                        }) {
                            Text(scoreSymbols)
                                .frame(width: geometry.size.height * 0.16, height: geometry.size.height * 0.08)
                                .responsiveFont(.title3)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .sheet(isPresented: $showHighScoreDetail) {
                            if #available(iOS 16.0, *) {
                                HighScoreDetailView(
                                    difficulty: Int(difficulty),
                                    op: selectedOperator,
                                    highScores: highScores
                                )
                                .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] :[.medium])
                                .presentationDragIndicator(.visible)
                            } else {
                                // Fallback for iOS <16: full-screen sheet
                                HighScoreDetailView(
                                    difficulty: Int(difficulty),
                                    op: selectedOperator,
                                    highScores: highScores
                                )
                            }
                        }
                        
                    }
                    // Show last problem with pass/fail mark and correct solution
                    // Show incorrect answer as well?
                    
                    HStack {
                        if let last = history.last {  // A problem was attemped
                            let isCorrect = last.correct
                            let symbolColor = isCorrect ? Color.green.opacity(0.85) : Color.red.opacity(0.85)
                            let iconName = isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
                            
                            Image(systemName: iconName)
                                .resizable()
                                .frame(width: screenDiagonal * 0.035, height: screenDiagonal * 0.035)
                                .foregroundColor(symbolColor)
                            if isCorrect {  // Passed last problem
                                Text("\(last.problem.num1) \(last.problem.symbol) \(last.problem.num2) = \(last.problem.answer)")
                                    .frame(maxWidth: .infinity, minHeight: 25, alignment: .leading)
                                    .responsiveFont(.subheadline)
                                    .padding(.leading, 10)
                                    .background(Color.black.opacity(0.8))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            } else {  // Failed last problem
                                Text("\(last.problem.num1) \(last.problem.symbol) \(last.problem.num2) = \(last.problem.answer) \u{2260} \(last.guess)")
                                    .frame(maxWidth: .infinity, minHeight: 25, alignment: .leading)
                                    .responsiveFont(.subheadline)
                                    .padding(.leading, 10)
                                    .background(Color.black.opacity(0.8))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        } else {  // history.last does not exist; no problem has been attempted yet
                            Image(systemName: "questionmark.circle.fill")
                                .resizable()
                                .frame(width: screenDiagonal * 0.035, height: screenDiagonal * 0.035)
                                .foregroundColor(.white.opacity(0.85))
                            
                            Text(" ")
                                .frame(maxWidth: .infinity, minHeight: 25, alignment: .leading)
                                .responsiveFont(.subheadline)
                                .padding(.leading, 10)
                                .background(Color.black.opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: geometry.size.width * 0.9)
//                    .background(Color.green.opacity(0.5))  // Debugging UI
                }
                .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.17)  // Size of history box
                //            .background(Color.orange.opacity(0.2))  // Debugging UI
                .padding(3)  // PADDING!!!
                .background(Color.black.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                
                // Problem Display - Display current problem and input for answer
                VStack {
                    Text("\(currentProblem.num1) \(currentProblem.symbol) \(currentProblem.num2) =")
                        .responsiveFont(.largeTitle)
                        .padding(4)
                        .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.10)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    HStack(spacing: 10) {
                        Text(userInput.isEmpty ? "?" : userInput)
                            .responsiveFont(.title)
                            .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.05)
                        //                        .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Button(action: {
                            userInput = String(userInput.dropLast())
                        }) {
                            Text("\u{232B}") // Unicode symbol for backspace (U+232B)
                                .responsiveFont(.title)
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
                        
                        Button(action: {
                            submitAnswer()
                        }) {
                            Text("\u{23CE}")  // Unicode "Enter"/"Carrige return"
                                .responsiveFont(.title2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundColor(.black)
                                .background(Color.white.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        // Same size as numpad buttons, see func numButton
                        .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.08)
                        .contentShape(Rectangle()) // Makes entire button tappable
                    }
                }
                .padding()
                .background(Color.orange)
                .frame(height: geometry.size.height * 0.36)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                // Difficulty Slider
                HStack {
                    Slider(value: $difficulty, in: ContentView.minDifficulty...ContentView.maxDifficulty, step: 1)
                        .accentColor(.green)
                        .frame(height: geometry.size.height * 0.05) // shorter height
                    // Show different colors to give an idea about difficulty
                    Text("\(Int(difficulty))")  // Box at the right displaying difficulty
                        .responsiveFont(.caption)
                        .frame(minWidth: geometry.size.width * 0.05)
                        .padding(6)
                        .background(ContentView.difficultyColor(for : difficulty))
                        .animation(.easeInOut(duration: 0.3), value: difficulty)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .padding(.horizontal)
                .frame(height: geometry.size.height * 0.03)
                
                
                // Operator Selection
                HStack {
                    ForEach(Operator.allCases, id: \.self) { op in
                        Button(action: {
                            highScores.updateIfHigher(streak: currentStreak, difficulty: Int(difficulty), op: selectedOperator)
                            currentStreak = 0
                            selectedOperator = op
                            newProblem()
                            history.removeAll()
                        }) {
                            Text("\(op.rawValue)")
                                .frame(width: geometry.size.width * 0.22, height: geometry.size.height * 0.08)
                                .responsiveFont(.title)
                                .background(op == selectedOperator ? Color.white.opacity(0.4) : Color.black.opacity(0.4))
                                .foregroundColor(op == selectedOperator ? Color.black : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .frame(height: geometry.size.height * 0.12)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.blue)
            .onAppear {
                newProblem()
            }
            .onChange(of: difficulty) { _ in
                // Don't run updateIfHigher here; that will give the old difficulty's streak to the new difficulty,
                // possibly setting the max streak of the new difficulty too high.
//                highScores.updateIfHigher(streak: currentStreak, difficulty: Int(difficulty), op: selectedOperator)
                currentStreak = 0
                newProblem()
                history.removeAll()
            }
            .sheet(isPresented: $showHighScores) {
                HighScoresView(highScores: highScores)
            }
        }
    }
    
    // MARK: - Helpers
    
    var scoreSymbols: String {
        let score = highScores.highScore(for: Int(difficulty), op: selectedOperator)
        return HighScoresView.trophyText(for: score)
    }
    
    func numButton(_ label: String, geometry: GeometryProxy) -> some View {
        Button(action: {
            userInput += label
        }) {
            Text(label)
                .responsiveFont(.title2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.white)
                .background(Color.black.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.08)
        .contentShape(Rectangle()) // ensures the full frame is tappable
    }
    
    func submitAnswer() {
        guard let guess = Int(userInput) else { return }
        let correct = guess == currentProblem.answer
        history.append((currentProblem, correct, guess))
        
        if correct {
            currentStreak += 1
        } else {
            currentStreak = 0
        }
        highScores.updateIfHigher(streak: currentStreak, difficulty: Int(difficulty), op: selectedOperator)
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
    
    static func difficultyColor(for difficulty: Double) -> Color {
        let saturation = Double((difficulty - minDifficulty) / (maxDifficulty - minDifficulty))
        return Color(hue: 0.1, saturation: saturation, brightness: 0.94)
    }
    
}
