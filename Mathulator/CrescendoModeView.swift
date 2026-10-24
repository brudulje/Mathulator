//
//  CrescendoModeView.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-11-02.
//

import SwiftUI

struct CrescendoModeView: View {
    @Binding var isPresented: Bool
    
    @StateObject private var session = GameSession(
        mode: .crescendo,
        startDifficulty: 6,
        selectedOperator: .add,
        highScores: HighScores.shared
    )
    init(isPresented: Binding<Bool>, selectedOperator: Operator, selectedLevel: CrescendoLevel) {
        _isPresented =  isPresented
        _session = StateObject(
            wrappedValue: GameSession(
                mode: .crescendo,
                startDifficulty: DifficultyConfig.minDifficulty,
                selectedOperator: selectedOperator,   //  use whatever operator the parent sends
                highScores: HighScores.shared,
                crescendoLevel: selectedLevel
            )
        )
    }
    
    static let minDifficulty = DifficultyConfig.minDifficulty
    
    @Environment(\.dismiss) private var dismiss
    
    //    @available(iOS 16.0, *)
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
                        //                        print("Pressed Close")
                        isPresented = false
                    }
                    .padding(.trailing, 10)
                    .buttonStyle(.plain)
                }
                
                // History
                HistoryView(
                    history: session.history,
                    markList: session.passFailMarkList,
                    scoreSymbols: session.crescendoMarksString,
                    difficulty: session.difficulty,
                    selectedOperator: session.selectedOperator,
                    mode: .crescendo,
                    showHighScoreDetail: .constant(false),
                    highScores: HighScores.shared,
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
                    onEnter: session.submitAnswer,
                    numPadBackgroundColor: Color.black.opacity(0)
                )
                .padding()
                .background(Color.black.opacity(0.3))
                .frame(width: geometry.size.width * 0.90,
                       height: geometry.size.height * 0.36)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Spacer()
                HStack {
                    Spacer()
                    // Difficulty display
                    DifficultyDisplayView(
                        difficulty: $session.difficulty
                    )
                    Spacer()
                    // Show remaining lives / forgiveness hearts
                    ForgivenessHeartsView(
                        remaining: session.remainingForgiveness,
                        total: session.crescendoLevel.allowedMistakes
                    )
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.05)
                    .padding(.horizontal)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.purple.opacity(0.7))
        }
        .onAppear {
            // Do nothing; GameSession handles this part
        }
        .sheet(isPresented: $session.showCrescendoSummary) {
            let summary = CrescendoSummaryView(
                difficulty: Int(session.difficulty),
                selectedOperator: session.selectedOperator,
                level: session.crescendoLevel,
                newRecordSet: session.newRecordSet,
                oldRecord: session.oldCrescendoRecord,
                newRecord: session.newCrescendoRecord,
                isPresented: $isPresented,
                onDismiss: {
                    session.showCrescendoSummary = false
                    session.mode = .normal
                }
            )
                .interactiveDismissDisabled(true)
            if #available(iOS 16.0, *) {
                summary
                    .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] : [.medium])
            } else {
                summary
            }
        }
    }
}

private struct ForgivenessHeartsView: View {
    let remaining: Int
    let total: Int

    // Customize these if you want different colors
    var availableFill: Color = .red
    var spentFill: Color = .white.opacity(0.3)
    var availableOutlineColor: Color = .black
    var spentOutlineColor: Color = .white.opacity(0.7) // optionally darker to keep visibility

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: geo.size.width * 0.04) {
                ForEach(0..<max(total, 0), id: \.self) { index in
                    let isAvailable = index < remaining
                    ZStack {
                        // Fill
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(isAvailable ? availableFill : spentFill)

                        // Outline
                        Image(systemName: "heart")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(isAvailable ? availableOutlineColor : spentOutlineColor)
                    }
                    .opacity(isAvailable ? 0.95 : 0.9)
                    .accessibilityLabel(isAvailable ? "Life available" : "Life spent")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(.easeInOut(duration: 0.25), value: remaining)
        }
    }
}
//
//private struct ForgivenessHeartsView: View {
//    let remaining: Int
//    let total: Int
//    var body: some View {
//        GeometryReader { geo in
//            HStack(spacing: geo.size.width * 0.04) {
//                ForEach(0..<max(total, 0), id: \.self) { index in
//                    let isAvailable = index < remaining
//                    Image(systemName: isAvailable ? "heart.fill" : "heart")
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundColor(isAvailable ? .red : .white)
//                        .opacity(isAvailable ? 0.95 : 0.85)
//                        .accessibilityLabel(isAvailable ? "Life available" : "Life spent")
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//            .animation(.easeInOut(duration: 0.25), value: remaining)
//        }
//    }
//}

