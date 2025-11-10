//
//  MainSections.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-11-02.
//

import SwiftUI

// MARK: - HeaderView

struct HeaderView<TrailingContent: View>: View {
    let title: String
    let mode: GameMode
    @Binding var showHighScores: Bool
    @Binding var showAbout: Bool
    @Binding var difficulty: Double
    @ViewBuilder var trailingContent: () -> TrailingContent
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Text("\(title)")
                    .responsiveFont(.headline, weight: .bold)
                    .padding(3)
                    .background(Color.black.opacity(0.2))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                HStack {
                    Spacer()
                    trailingContent()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - HistoryView

struct HistoryView: View {
    let history: [(problem: MathProblem, correct: Bool, guess: Int)]
    let markList: [Bool]
    let scoreSymbols: String
    let difficulty: Double
    let selectedOperator: Operator
    let mode: GameMode
    
    @Binding var showHighScoreDetail: Bool
    @ObservedObject var highScores: HighScores
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    let symbols = markList.map { $0 ? "checkmark.circle.fill" : "xmark.circle.fill" }
                    let maxSymbols = 24
                    let filledSymbols = Array(symbols.suffix(maxSymbols))
                    let paddedSymbols = filledSymbols + Array(repeating: "questionmark.circle.fill", count: maxSymbols - filledSymbols.count)
//                    if mode == .crescendo {
//                        scoreSymbols = session.history
//                            .suffix(3)
//                            .map { $0.correct ? "checkmark.circle.fill" : "xmark.circle.fill" }
//                            .joined(),
//                    }
                    VStack(spacing: geometry.size.height * 0.02) { // example scaling
                        ForEach(0..<3, id: \.self) { row in
                            HStack(spacing: geometry.size.width * 0.01) {
                                ForEach(0..<8, id: \.self) { col in
                                    let index = row * 8 + col
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
                    if mode == .normal {
                        Button(action: { showHighScoreDetail = true }) {
                            Text(scoreSymbols)
                                .frame(width: geometry.size.width * 0.3, height:  geometry.size.width * 0.12)
                                .responsiveFont(.title3)
                                .padding(.vertical, geometry.size.height * 0.05)
                                .background(Color.white.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .sheet(isPresented: $showHighScoreDetail) {
                                let scoreDetail = HighScoreDetailView(
                                    difficulty: Int(difficulty),
                                    op: selectedOperator,
                                    highScores: highScores
                                )
                            if #available(iOS 16.0, *) {
                            scoreDetail
                                .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] : [.medium])
                                .presentationDragIndicator(.visible)
                            } else {
                                scoreDetail                            }
                        }
                    } else if mode == .crescendo {
                        Text(scoreSymbols)
                            .frame(width: geometry.size.width * 0.3, height:  geometry.size.width * 0.12)
                            .responsiveFont(.title3)
                            .animation(.easeInOut(duration: 0.3), value: scoreSymbols)
                            .padding(.vertical, geometry.size.height * 0.05)
                            .background(Color.white.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
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
                            .frame(width: geometry.size.width * 0.85,
                                   height: geometry.size.height * 0.2,
                                   alignment: .leading)
                            .responsiveFont(.callout)
                            .padding(.leading, geometry.size.width * 0.02)
                            .background(Color.black.opacity(0.85))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    } else {
                        Image(systemName: "questionmark.circle.fill")
                            .resizable()
                            .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                            .foregroundColor(.white.opacity(0.85))
                        Text(" ")
                            .frame(width: geometry.size.width * 0.85,
                                   height: geometry.size.height * 0.2,
                                   alignment: .leading)
                            .responsiveFont(.callout)
                            .padding(.leading, geometry.size.width * 0.02)
                            .background(Color.black.opacity(0.85))
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
    var onBackspace: () -> Void
    @Binding var userInput: String
    
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
    var numPadBackgroundColor: Color = .orange
    
    var body: some View {
        VStack(spacing: 3) {
            ForEach([[7,8,9],[4,5,6],[1,2,3]], id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { num in
                        numButton("\(num)")
                    }
                }
            }
            HStack(spacing: 10) {
                numButton("-")
                numButton("0")
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
        .background(numPadBackgroundColor)
        //        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
    
    func numButton(_ label: String) -> some View {
        Button(action: {
            onTap(label)
        }) {
            Text(label)
                .responsiveFont(.title2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.white)
                .background(Color.black.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        //            .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.08)
        .contentShape(Rectangle()) // ensures the full frame is tappable
    }
    
}

// MARK: - DifficultySliderView

struct DifficultySliderView: View {
    let minDifficulty: Double
    let maxDifficulty: Double
    @Binding var difficulty: Double
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Slider(value: $difficulty, in: minDifficulty...maxDifficulty, step: 1)
                    .accentColor(.green)
                Button (action: { difficulty += 1 }){
                    Text("\(Int(difficulty))")
                        .frame(minWidth: geometry.size.width * 0.06)
                        .responsiveFont(.caption)
                        .padding(6)
                        .background(ContentView.difficultyColor(for: difficulty))
                        .foregroundColor(Color.black)
                        .animation(.easeInOut(duration: 0.3), value: difficulty)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - DifficultyDisplayView

struct DifficultyDisplayView: View {
    @Binding var difficulty: Double
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text("\(Int(difficulty))")
                    .frame(minWidth: geometry.size.width * 0.2, minHeight: geometry.size.width * 0.2)
                    .responsiveFont(.body)
                    .padding(6)
                    .background(ContentView.difficultyColor(for: difficulty))
                    .animation(.easeInOut(duration: 0.3), value: difficulty)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0))
            .cornerRadius(10)
        }
    }
}

// MARK: - OperatorSelectionView

struct OperatorSelectionView: View {
    @Binding var selectedOperator: Operator
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
