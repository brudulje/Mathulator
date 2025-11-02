//
//  ContentView.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-07-04.
//

import SwiftUI

struct ContentView: View {
    @State private var showHighScoreDetail = false
    @State private var showAbout = false
    @State private var presentingCrescendo = false
    @State private var showHighScores = false
    
    @StateObject private var session = GameSession(
        mode: .normal,
        startDifficulty: 11,
        selectedOperator: .add,
        highScores: HighScores.shared
    )
    @StateObject private var highScores = HighScores()
    
    static let minDifficulty = DifficultyConfig.minDifficulty
    static let maxDifficulty = DifficultyConfig.maxDifficulty
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 7) {
                // Header
                HeaderView(title: "Mathulator",
                           mode: .normal,
                           showHighScores: $showHighScores,
                           showAbout: $showAbout,
                           difficulty: $session.difficulty,
                ){
                    Menu {
                        Button("🏆 Trophies") { showHighScores = true }
                        Button("\u{1F4C8} Crescendo Mode") {
//                            session.enterCrescendo()   // sets session.mode + difficulty
                            presentingCrescendo = true // triggers cover reliably
                        }
                        
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
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.10)
                //                    .background(Color.green)  // debugging
                
                // History
                HistoryView(
                    history: session.history,
                    scoreSymbols: scoreSymbols,
                    difficulty: session.difficulty,
                    selectedOperator: session.selectedOperator,
                    mode: .normal,
                    showHighScoreDetail: $showHighScoreDetail,
                    highScores: highScores,
                    
                )
                .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.18)
                //                .background(Color.red)  // debugging
                .padding(3)
                
                // Problem display
                ProblemDisplayView(
                    problem: session.currentProblem,
                    onBackspace: { session.userInput = String(session.userInput.dropLast()) },
                    userInput: $session.userInput,
                )
                .padding(.horizontal)
                .frame(height: geometry.size.height * 0.18)
                //                .background(Color.white)  // debugging
                
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
                
                // Difficulty slider
                DifficultySliderView(
                    minDifficulty: DifficultyConfig.minDifficulty,
                    maxDifficulty: DifficultyConfig.maxDifficulty,
                    difficulty: $session.difficulty,
                )
                .padding(.horizontal)
                .frame(height: geometry.size.height * 0.05)
                
                // Operator selection
                OperatorSelectionView(
                    selectedOperator: $session.selectedOperator,
                    difficulty: $session.difficulty,
                    highScores: highScores,
                    onOperatorChange: { op in
                        session.handleOperatorChange(op)
                    }
                )
                .frame(width: geometry.size.width,
                       height: geometry.size.height * 0.1)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.blue)
            .onAppear {
                // Do nothing: GameSession handles this
            }
            .onChange(of: session.difficulty) { _ in 
                if session.mode == .normal{
                    session.currentStreak = 0
                    session.newProblem()
                    session.history.removeAll()
                }
            }
            .sheet(isPresented: $showHighScores) {
                HighScoresView(highScores: highScores)
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .fullScreenCover(
                isPresented: $presentingCrescendo,
                onDismiss: {
//                    session.switchMode(to: .normal)
                }
            ) {
                CrescendoModeView(selectedOperator: session.selectedOperator)
            }
        }
    }
    
    // MARK: - Helpers
    
    var scoreSymbols: String {
        let score = highScores.highScore(for: Int(session.difficulty), op: session.selectedOperator)
        return HighScoresView.trophyText(for: score)
    }
    
    static func difficultyColor(for difficulty: Double) -> Color {
        let saturation = Double((difficulty - minDifficulty) / (maxDifficulty - minDifficulty))
        return Color(hue: 0.1, saturation: saturation, brightness: 0.94)
    }
    
}
