//
//  HighScoresView.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-08-31.
//

import SwiftUI

struct HighScoresView: View {
    @ObservedObject var highScores: HighScores
    @State private var selectedDetail: ScoreDetail?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    let firstColunmWidth = 0.1
                    let otherColumnWidth = 0.17
                    let tableColumnsWidth = 0.16
                    HStack {
                        // Fixed top row in High scores
                        Text("")  // Empty space in tio left corner
                            .frame(width: geometry.size.width * firstColunmWidth, alignment: .center)
                            .responsiveFont(.caption)
                            .padding(4)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        // Show each operator on top of their columns
                        ForEach(Operator.allCases, id: \.self) { op in
                            Text(op.rawValue)
                                .frame(width: geometry.size.width * otherColumnWidth,
                                       height: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.height * 0.09 : geometry.size.height * 0.06, alignment: .center)
                                .responsiveFont(.title2)
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
                                        .frame(width: geometry.size.width * firstColunmWidth, alignment: .center)
                                        .responsiveFont(.caption)
                                        .padding(4)
                                        .foregroundColor(Color.black)
                                        .background(ContentView.difficultyColor(for: Double(difficulty)))
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                    
                                    ForEach(Operator.allCases, id: \.self) { op in
                                        let score = highScores.highScore(for: difficulty, op: op)
                                        let symbols = HighScoresView.trophyText(for: score)
                                        Button(action: {
                                            selectedDetail = ScoreDetail(difficulty: difficulty, op: op)
                                        }) {
                                            Text(symbols)
                                                .frame(width: geometry.size.width * tableColumnsWidth)
                                                .responsiveFont(.caption2)
                                                .padding(4)
                                                .background(HighScoresView.highScoreBackgroundColor(for: score))
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("\u{1F3C6}\u{1F3C6}\u{1F3C6}")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                .sheet(item: $selectedDetail) { detail in
                    if #available(iOS 16.0, *) {
                        HighScoreDetailView(
                            difficulty: detail.difficulty,
                            op: detail.op,
                            highScores: highScores
                        )
                        .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] :[.medium])
                        .presentationDragIndicator(.visible)
                    } else {
                        HighScoreDetailView(
                            difficulty: detail.difficulty,
                            op: detail.op,
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

struct ScoreDetail: Identifiable {
    let id = UUID()
    let difficulty: Int
    let op: Operator
}
