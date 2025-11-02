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
    @State private var showAbout = false
    
    @StateObject private var highScores = HighScores()
    
    static let minDifficulty = DifficultyConfig.minDifficulty
    static let maxDifficulty = DifficultyConfig.maxDifficulty
    
    
    var body: some View {
        GeometryReader { geometry in
            let screenDiagonal = sqrt(geometry.size.width * geometry.size.width + geometry.size.height * geometry.size.height)
            VStack(spacing: 7) {
                // Header
                HeaderView(showHighScores: $showHighScores, showAbout: $showAbout)
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.10)
//                    .background(Color.green)  // debugging

                // History
                HistoryView(
                    history: history,
                    screenDiagonal: screenDiagonal,
                    showHighScoreDetail: $showHighScoreDetail,
                    scoreSymbols: scoreSymbols,
                    difficulty: difficulty,
                    selectedOperator: selectedOperator,
                    highScores: highScores
                )
                .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.18)
//                .background(Color.red)  // debugging
                .padding(3)

                // Problem display
                ProblemDisplayView(
                    problem: currentProblem,
                    userInput: $userInput,
                    onBackspace: { userInput = String(userInput.dropLast()) }
                )
                .padding(.horizontal)
                .frame(height: geometry.size.height * 0.18)
//                .background(Color.white)  // debugging

                // Numpad
                NumpadView(
                    onTap: { userInput += $0 },
                    onEnter: submitAnswer
                )
                .padding()
                .background(Color.orange)
                .frame(width: geometry.size.width * 0.90,
                       height: geometry.size.height * 0.36)
                .clipShape(RoundedRectangle(cornerRadius: 15))

                // Difficulty slider
                DifficultySliderView(
                    difficulty: $difficulty,
                    minDifficulty: ContentView.minDifficulty,
                    maxDifficulty: ContentView.maxDifficulty
                )
                .padding(.horizontal)
                .frame(height: geometry.size.height * 0.05)

                // Operator selection
                OperatorSelectionView(
                    selectedOperator: $selectedOperator,
                    currentStreak: $currentStreak,
                    difficulty: $difficulty,
                    highScores: highScores,
                    onOperatorChange: { op in
                        highScores.updateIfHigher(streak: currentStreak, difficulty: Int(difficulty), op: selectedOperator)
                        currentStreak = 0
                        selectedOperator = op
                        newProblem()
                        history.removeAll()
                    }
                )
                .frame(width: geometry.size.width,
                       height: geometry.size.height * 0.1)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.blue)
            .onAppear {
                newProblem()
            }
            .onChange(of: difficulty) { _ in
                
                currentStreak = 0
                newProblem()
                history.removeAll()
            }
            .sheet(isPresented: $showHighScores) {
                HighScoresView(highScores: highScores)
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
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
