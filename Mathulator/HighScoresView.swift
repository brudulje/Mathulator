//
//  HighScoresView.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-08-31.
//

import SwiftUI

struct HighScoresView: View {
    @ObservedObject var highScores: HighScores
    @State private var selectedDifficulty: Int? = nil
    @State private var selectedOperator: Operator? = nil
    @State private var showDetail = false
    
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
                                .frame(width: geometry.size.width * 0.1618, height: geometry.size.width * 0.1, alignment: .center)
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
                                        .foregroundColor(Color.black)
                                        .background(ContentView.difficultyColor(for: Double(difficulty)))
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                    
                                    ForEach(Operator.allCases, id: \.self) { op in
                                        let score = highScores.highScore(for: difficulty, op: op)
                                        let symbols = HighScoresView.trophyText(for: score)
                                        Button(action: {
                                            selectedDifficulty = difficulty
                                            selectedOperator = op
                                            showDetail = true
                                        }) {
                                            Text(symbols)
                                                .frame(width: geometry.size.width * 0.15)
                                                .font(.caption)
                                                .padding(4)
                                                .background(HighScoresView.highScoreBackgroundColor(for: score))
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                        }
//                                        Text("\(symbols)")
//                                            .frame(width: geometry.size.width * 0.15)  // 4 operators × 0.18 = ~0.72 + 0.15 = ~0.87
//                                            .font(.caption)
//                                            .padding(4)
//                                            // Custom colors for various score levels
//                                            .background(HighScoresView.highScoreBackgroundColor(for: score))
//                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("\u{1F3C6}\u{1F3C6}\u{1F3C6}")  // "\u{1F3C6} High scores \u{1F3C6}"Unicode "Trophy"
                .navigationBarTitleDisplayMode(.inline)
            }
            .sheet(isPresented: $showDetail) {
                if let difficulty = selectedDifficulty, let op = selectedOperator {
                    if #available(iOS 16.0, *) {
                        HighScoreDetailView(
                            difficulty: difficulty,
                            op: op,
                            highScores: highScores
                        )
                        .presentationDetents([.medium])//[.medium, .large]) // start medium, expandable
                        .presentationDragIndicator(.visible)
                    } else {
                        // Fallback on earlier versions
                        HighScoreDetailView(
                            difficulty: difficulty,
                            op: op,
                            highScores: highScores
                        )
                    }

                }
            }
        }
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

    static func highScoreBackgroundColor(for score: Int) -> Color {
        switch score {
        case 0:
            return Color.gray.opacity(0.1)
        case 1...:
            return Color.blue.opacity(0.3)
        default:
            return Color.gray.opacity(0.1)
        }
    }
}

