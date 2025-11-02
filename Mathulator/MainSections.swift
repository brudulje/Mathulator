//
//  MainSections.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-11-02.
//

import SwiftUI

// MARK: - HeaderView

struct HeaderView: View {
    @Binding var showHighScores: Bool
    @Binding var showAbout: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Text("Mathulator")
                    .responsiveFont(.headline, weight: .bold)
                    .padding(3)
                    .background(Color.black.opacity(0.2))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                HStack {
                    Spacer()
                    Menu {
                        Button("🏆 Trophies") { showHighScores = true }
                        Divider()
                        Button("ℹ About") { showAbout = true }
                    } label: {
                        Text("☰")
                            .frame(width: geometry.size.width * 0.1,
                                   height: geometry.size.width * 0.1)
                            .responsiveFont(.title)
                            .foregroundColor(Color.white)
                            .background(Color.black.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding(.trailing, 6)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - HistoryView

struct HistoryView: View {
    let history: [(problem: MathProblem, correct: Bool, guess: Int)]
    let screenDiagonal: CGFloat
    @Binding var showHighScoreDetail: Bool
    let scoreSymbols: String
    let difficulty: Double
    let selectedOperator: Operator
    @ObservedObject var highScores: HighScores
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    let symbols = history.map { $0.correct ? "checkmark.circle.fill" : "xmark.circle.fill" }
                    let maxSymbols = 24
                    let filledSymbols = Array(symbols.suffix(maxSymbols))
                    let paddedSymbols = filledSymbols + Array(repeating: "questionmark.circle.fill", count: maxSymbols - filledSymbols.count)
                    
                    HStack(spacing: geometry.size.height * 0.02) { // example scaling
                        ForEach(0..<8, id: \.self) { col in
                            VStack(spacing: geometry.size.width * 0.01) {
                                ForEach(0..<3, id: \.self) { row in
                                    let index = col * 3 + row // row * 7 + col
                                    Image(systemName: paddedSymbols[index])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(
                                            width: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.04 : geometry.size.width * 0.05,
                                            height: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.04 : geometry.size.width * 0.05
                                        )
                                        .foregroundColor(
                                            paddedSymbols[index] == "checkmark.circle.fill" ? .green :
                                                paddedSymbols[index] == "xmark.circle.fill" ? .red.opacity(0.85) : .white.opacity(0.85)
                                        )
                                }
                            }
                        }
                    }
                    Button(action: { showHighScoreDetail = true }) {
                        Text(scoreSymbols)
                            .frame(width: geometry.size.width * 0.3, height:  geometry.size.width * 0.12)
                            .responsiveFont(.title3)
                            .padding(.vertical, geometry.size.height * 0.05)
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
                            .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] : [.medium])
                            .presentationDragIndicator(.visible)
                        } else {
                            HighScoreDetailView(
                                difficulty: Int(difficulty),
                                op: selectedOperator,
                                highScores: highScores
                            )
                        }
                    }
                }
                
                HStack {
                    if let last = history.last {
                        let isCorrect = last.correct
                        let symbolColor = isCorrect ? Color.green.opacity(0.85) : Color.red.opacity(0.85)
                        let iconName = isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
                        
                        Image(systemName: iconName)
                            .resizable()
                            .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                            .foregroundColor(symbolColor)
                        Text("\(last.problem.num1) \(last.problem.symbol) \(last.problem.num2) = \(last.problem.answer)\(isCorrect ? "" : " ≠ \(last.guess)")")
                            .frame(width: geometry.size.width * 0.8)
                            .responsiveFont(.subheadline)
                            .padding(.leading, geometry.size.width * 0.02)
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    } else {
                        Image(systemName: "questionmark.circle.fill")
                            .resizable()
                            .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                            .foregroundColor(.white.opacity(0.85))
                        Text(" ")
                            .frame(width: geometry.size.width * 0.8)
                            .responsiveFont(.subheadline)
                            .padding(.leading, geometry.size.width * 0.02)
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - ProblemDisplayView

struct ProblemDisplayView: View {
    let problem: MathProblem
    @Binding var userInput: String
    var onBackspace: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("\(problem.num1) \(problem.symbol) \(problem.num2) =")
                    .responsiveFont(.largeTitle)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                HStack(spacing: 10) {
                    Text(userInput.isEmpty ? "?" : userInput)
                        .responsiveFont(.title)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Button(action: onBackspace) {
                        Text("⌫")
                            .frame(maxWidth: geometry.size.width * 0.20)
//                        ,
//                                   maxHeight: geometry.size.height * 0.05)
                            .responsiveFont(.title)
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - NumpadView

struct NumpadView: View {
    var onTap: (String) -> Void
    var onEnter: () -> Void

    var body: some View {
        VStack(spacing: 3) {
            ForEach([[7,8,9],[4,5,6],[1,2,3]], id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { num in
                        Button(action: { onTap("\(num)") }) {
                            Text("\(num)")
                                .responsiveFont(.title2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
            HStack(spacing: 10) {
                Button(action: { onTap("-") }) {
                    Text("-")
                        .responsiveFont(.title2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Button(action: { onTap("0") }) {
                    Text("0")
                        .responsiveFont(.title2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Button(action: onEnter) {
                    Text("⏎")
                        .responsiveFont(.title2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.black)
                        .background(Color.white.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.orange)
//        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

// MARK: - DifficultySliderView

struct DifficultySliderView: View {
    @Binding var difficulty: Double
    let minDifficulty: Double
    let maxDifficulty: Double
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Slider(value: $difficulty, in: minDifficulty...maxDifficulty, step: 1)
                    .accentColor(.green)
                Text("\(Int(difficulty))")
                    .frame(minWidth: geometry.size.width * 0.05)
                    .responsiveFont(.caption)
                    .padding(6)
                    .background(ContentView.difficultyColor(for: difficulty))
                    .animation(.easeInOut(duration: 0.3), value: difficulty)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - OperatorSelectionView

struct OperatorSelectionView: View {
    @Binding var selectedOperator: Operator
    @Binding var currentStreak: Int
    @Binding var difficulty: Double
    @ObservedObject var highScores: HighScores
    var onOperatorChange: (Operator) -> Void

    var body: some View {
        HStack (spacing: 0) {
            ForEach(Operator.allCases, id: \.self) { op in
                Button(action: {
                    onOperatorChange(op)
                }) {
                    Text("\(op.rawValue)")
                        .responsiveFont(.title)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(op == selectedOperator ? Color.white.opacity(0.4) : Color.black.opacity(0.4))
                        .foregroundColor(op == selectedOperator ? Color.black : Color.white)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
