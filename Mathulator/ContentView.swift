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
    
    static let minDifficulty = DifficultyConfig.minDifficulty
    static let maxDifficulty = DifficultyConfig.maxDifficulty

var body: some View {
    GeometryReader { geometry in
        VStack(spacing: 9) {
            // Top Row: Logo and High score
            ZStack {
                // Logo
                Text("Mathulator")
                    .font(.headline)
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
                            .font(.headline)
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
                    let maxSymbols = 20
                    let filledSymbols = Array(symbols.suffix(maxSymbols))
                    let paddedSymbols = filledSymbols + Array(repeating: "questionmark.circle.fill", count: maxSymbols - filledSymbols.count)
                    // Show pass/fail for latest 20 problems attempted
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
                                                paddedSymbols[index] == "xmark.circle.fill" ? .red.opacity(0.85) : .white.opacity(0.85)
                                        )
                                }.animation(.easeInOut, value: history.count)
                            }
                        }
                    }
                    // Score percentage, will probably be changed to trophies
//                    let score = highScores.highScore(for: difficulty, op: selectedOperator)
//                    let symbols = trophyText(for: score)
                    Text(scoreSymbols)
                        .frame(width: geometry.size.height * 0.15, height: geometry.size.height * 0.08)  // WIP
                        .font(.title3)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        .frame(width: geometry.size.height * 0.15, height: geometry.size.height * 0.10)  // WIP
                    
                }
                // Show last problem wil pass/fail mark and correct solution
                // Show incorrect answer as well?
                HStack {
                    if let last = history.last {
                        Image(systemName: last.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(last.correct ? .green : .red.opacity(0.85))
                    } else {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.white)
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
            }  .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.12)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

            
            // Problem Display - Display current problem and input for answer
            VStack {
                Text("\(currentProblem.num1) \(currentProblem.symbol) \(currentProblem.num2) =")
                    .font(.largeTitle)
                    .padding(4)
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.10)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            
                HStack(spacing: 10) {
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
                    
                    Button(action: {
                        submitAnswer()
                    }) {
                        Text("\u{23CE}")  // Unicode "Enter"/"Carrige return"
                            .font(.title2)
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
                    .frame(height: geometry.size.height * 0.04) // shorter height
                // Show different colors to give an idea about difficulty
                Text("\(Int(difficulty))")
                    .font(.caption)
                    .frame(minWidth: geometry.size.width * 0.05)
                    .padding(6)
                    .background(ContentView.difficultyColor(for : difficulty))
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
                    Button(action: {
                        highScores.updateIfHigher(streak: currentStreak, difficulty: Int(difficulty), op: selectedOperator)
                        currentStreak = 0
                        selectedOperator = op
                        newProblem()
                        history.removeAll()
                    }) {
                        Text("\(op.rawValue)")
                        
                            .frame(width: geometry.size.width * 0.22, height: geometry.size.height * 0.08)
                            .font(.title)
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
    
    // MARK: - HighScoreView
    
    struct HighScoresView: View {
        @ObservedObject var highScores: HighScores

        var body: some View {
            GeometryReader { geometry in
                NavigationView {
                    VStack {
                        
                        HStack {
                            // Fixed top row in High scores
                            Text("")
                                .frame(width: geometry.size.width * 0.15, alignment: .center)
                                .font(.caption)
                                .padding(4)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            // Show each operator on top of their columns
                            ForEach(Operator.allCases, id: \.self) { op in
                                Text(op.rawValue)
                                    .frame(width: geometry.size.width * 0.16, height: geometry.size.height * 0.06, alignment: .center)
                                    .font(.title2)
//                                    .padding(1)
                                    .foregroundColor(Color.white)
                                    .background(
                                            ZStack {
                                                Color.blue
                                                Color.black.opacity(0.3)
                                            }
                                        )//.background(Color.blue.opacity(0.8))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                        }
                        
                        // List entire high score table
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                
                                ForEach(HighScores.difficulties, id: \.self) { difficulty in
                                    HStack(spacing: 4) {
                                        // Use custom colors for each row heading
                                        Text("\(difficulty)")
                                            .frame(width: geometry.size.width * 0.15, alignment: .center)
                                            .font(.caption)
                                            .padding(4)
                                            .foregroundColor(difficultyTextColor(for: Double(difficulty)))
                                            .background(ContentView.difficultyColor(for: Double(difficulty)))
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                        
                                        ForEach(Operator.allCases, id: \.self) { op in
                                            let score = highScores.highScore(for: difficulty, op: op)
                                            let symbols = trophyText(for: score)
                                            Text("\(symbols)")
                                                .frame(width: geometry.size.width * 0.15)  // 4 operators × 0.18 = ~0.72 + 0.15 = ~0.87
                                                .font(.caption)
                                                .padding(4)
                                                // Custom colors for various score levels
                                                .foregroundColor(highScoreTextColor(for: score))
                                                .background(highScoreBackgroundColor(for: score))
//                                                .background(Color.black.opacity(0.2))
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
//                    .navigationTitle("\u{1F3C6}        \u{1F3C6}        \u{1F3C6}        \u{1F3C6}        \u{1F3C6}")  // Unicode "Trophy"
                    .navigationTitle("\u{1F3C6} High scores \u{1F3C6}")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
    
    var scoreSymbols: String {
        let score = highScores.highScore(for: Int(difficulty), op: selectedOperator)
        return ContentView.trophyText(for: score)
    }
    // MARK: - Helpers

    func numButton(_ label: String, geometry: GeometryProxy) -> some View {
        Button(action: {
            userInput += label
        }) {
            Text(label)
                .font(.title2)
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
        history.append((currentProblem, correct))
        
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
    
    static func highScoreBackgroundColor(for score: Int) -> Color {
        switch score {
        case 0:
            return Color.gray.opacity(0.1)
        case 1...:
            return Color.blue.opacity(0.3)
//        case 7...11:
//            return Color.red.opacity(0.4)
//        case 12...19:
//            return Color.yellow.opacity(0.4)
//        case 20...:
//            return Color.green.opacity(0.4)
        default:
            return Color.gray.opacity(0.1)
        }
    }
        
        static func highScoreTextColor(for score: Int) -> Color {
            switch score {
            case 0:
                return Color.gray.opacity(0.5)
            case 1...:
                return Color.black
            default:
                return Color.black
            }
    }
    
//    static func difficultyHue(for difficulty: Double) -> Double {
//        return Double((difficulty - minDifficulty) / (maxDifficulty - minDifficulty))
//    }

    static func difficultySaturation(for difficulty: Double) -> Double {
        return Double((difficulty - minDifficulty) / (maxDifficulty - minDifficulty))
    }
    static func difficultyColor(for difficulty: Double) -> Color {
//        let hue = difficultyHue(for: difficulty)
        let saturation = difficultySaturation(for: difficulty)
        return Color(hue: 0.1, saturation: saturation, brightness: 0.94)
    }

    static func difficultyTextColor(for difficulty: Double) -> Color {
//        let hue = difficultyHue(for: difficulty)
//        switch hue {
//        case 0.0..<0.1:
//            return .white
//        case 0.1..<0.6:
//            return .black
//        default:
//            return .white
//        }
        return Color.black
    }
    
    static func trophyText(for score: Int) -> String {
        switch score {
        case 0...4:
            return ""
        case 5...11:
            return "\u{1F31F}"  // Unicode star
        case 12...19:
            return "\u{1F31F} \u{1F3C5}"  // Unicode star, medal
        case 20...:
            return "\u{1F31F}\u{1F3C5}\u{1F451}"  // Unicode star, medal, crown
        default:
            return "\(score)"
        }
    }
}
