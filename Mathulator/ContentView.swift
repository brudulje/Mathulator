//
//  ContentView.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-07-04.
//

import SwiftUI

struct ContentView: View {
    @State private var showAbout = false
    @State private var showHighScores = false
    @State private var showHighScoreDetail = false
    @State private var showingCrescendoSetup = false
    @State private var presentingCrescendo = false
    @State private var showMedals = false
    
    @StateObject private var session = GameSession(
        mode: .normal,
        startDifficulty: 11,
        selectedOperator: .add,
        highScores: HighScores.shared
        
    )
    
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
                        Button("\u{1F3C5} Medals") { showMedals = true }
                        Divider()
                        Button("📈 Crescendo Mode") {  // \u{1F4C8}
                            showingCrescendoSetup = true
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
                    markList: session.passFailMarkList,
                    scoreSymbols: scoreText(for: Int(session.difficulty), selectedOperator: session.selectedOperator),
                    difficulty: session.difficulty,
                    selectedOperator: session.selectedOperator,
                    mode: .normal,
                    showHighScoreDetail: $showHighScoreDetail,
                    highScores: HighScores.shared,
                    
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
                    highScores: HighScores.shared,
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
            .fullScreenCover(
                isPresented: $presentingCrescendo,
                onDismiss: {
//                    print("Dismissing full screen cover")
                    session.mode = .normal
                }
            ) {
                CrescendoModeView(isPresented: $presentingCrescendo,
                                  selectedOperator: session.selectedOperator
                                  )
            }
            .sheet(isPresented: $showHighScores) {
                HighScoresView(highScores: HighScores.shared)
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .sheet(isPresented: $showMedals) {
                CrescendoScoresView(crescendoScores: CrescendoScores.shared)
            }
            .sheet(
                isPresented: $showingCrescendoSetup,
                onDismiss: {
                    if session.mode == .crescendo {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            presentingCrescendo = true
                        }
                    }
                }) {
                    let crescendo = CrescendoStartView(
                        onStart: { selectedOp in
                            session.startCrescendo(with: selectedOp)
                            showingCrescendoSetup = false
                            //                            presentingCrescendo = true
                        },
                        highScores: HighScores.shared,
                        difficulty: $session.difficulty
                    )
                    if #available(iOS 16.0, *) {
                        crescendo
                            .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] :[.medium])
                            .presentationDragIndicator(.visible)
                    } else {
                        crescendo
                    }
                }

        }
    }
    
    // MARK: - Helpers
    
    func scoreText(for difficulty: Int, selectedOperator: Operator) -> String {
        let score = HighScores.shared.highScore(for: Int(difficulty), op: selectedOperator)
        return HighScoresView.trophyText(for: score)
    }
    
    static func difficultyColor(for difficulty: Double) -> Color {
        let saturation = Double((difficulty - minDifficulty) / (maxDifficulty - minDifficulty))
        return Color(hue: 0.1, saturation: saturation, brightness: 0.94)
    }
    
}
