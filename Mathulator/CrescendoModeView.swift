//
//  CrescendoModeView.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-11-02.
//

import SwiftUI

struct CrescendoModeView: View {
    @StateObject private var session = GameSession(
        mode: .crescendo,
        startDifficulty: 6,
        selectedOperator: .add,
        highScores: HighScores.shared
    )
    init(selectedOperator: Operator) {
        _session = StateObject(
            wrappedValue: GameSession(
                mode: .crescendo,
                startDifficulty: DifficultyConfig.minDifficulty,
                selectedOperator: selectedOperator,   //  use whatever operator the parent sends
                highScores: HighScores.shared
            )
        )
    }
    
    static let minDifficulty = DifficultyConfig.minDifficulty
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 7) {
                // Header
                HeaderView(title: "Crescendo Mode",
                           mode: .crescendo,
                           showHighScores: .constant(false),
                           showAbout: .constant(false),
                           difficulty: $session.difficulty,
                ){
                    Button("Close") {
                        dismiss()
                    }
                    .padding(.trailing, 10)
                }
                
                // History
                HistoryView(
                    history: session.history,
                    scoreSymbols: "",  // scoreSymbols not used for crescendo mode
                    difficulty: session.difficulty,
                    selectedOperator: session.selectedOperator,
                    mode: .crescendo,
                    showHighScoreDetail: .constant(false),
                    highScores: session.highScores,
                )
                .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.18)
                .padding(3)
                
                // Problem
                ProblemDisplayView(
                    problem: session.currentProblem,
                    onBackspace: { session.userInput = String(session.userInput.dropLast()) },
                    userInput: $session.userInput,
                    
                )
                .padding(.horizontal)
                .frame(height: geometry.size.height * 0.18)
                
                // Numpad
                NumpadView(
                    onTap: { session.userInput += $0 },
                    onEnter: session.submitAnswer
                )
                .padding()
                .background(Color.orange)
                .frame(width: geometry.size.width * 0.90,
                       height: geometry.size.height * 0.36)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Spacer()
                // Difficulty display
                DifficultyDisplayView(
                    difficulty: $session.difficulty,
                )
                .padding(.horizontal)
                .frame(height: geometry.size.height * 0.15)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.purple.opacity(0.7))
        }
        .onAppear {
            // Do nothing; GameSession handles this part
        }
    }
}
