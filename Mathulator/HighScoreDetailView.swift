//
//  HighScoreDetailView.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-08-31.
//
import SwiftUI

struct HighScoreDetailView: View {
    let difficulty: Int
    let op: Operator
    @ObservedObject var highScores: HighScores
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Text("\u{1F3C6}")
                    .font(.title)
                
//                Text("Difficulty: \(difficulty)")
                Text("\(op.rawValue)")
                    .frame(width: geometry.size.width * 0.21, height: geometry.size.width * 0.13)
                    .font(.title)
                    .background(ZStack{
                        Color.blue
                        Color.black.opacity(0.4)
                    })//.opacity(0.4) )
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                ZStack {
                    let score = highScores.highScore(for: difficulty, op: op)
                    let symbols = HighScoresView.trophyText(for: score)

                    HStack{
                        Text("\(difficulty)")
                            .frame(width: geometry.size.width * 0.21, alignment: .center)
                            .font(.caption)
                            .padding(4)
                            .foregroundColor(Color.black)
                            .background(ContentView.difficultyColor(for: Double(difficulty)))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        Spacer()
                        Text("\(score)").font(.title)
                    }
                    Text(symbols)
                        .frame(width: geometry.size.width * 0.21, height: geometry.size.width * 0.13)
                        .font(.caption)
                        .padding(4)
                        .background(HighScoresView.highScoreBackgroundColor(for: score))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
//                Text("Operator: \(op.rawValue)")
                
                let score = highScores.highScore(for: difficulty, op: op)
//                Text("Current Streak: \(score)")
//                    .font(.largeTitle)
                
                Button(role: .destructive) {
                    highScores.reset(difficulty: difficulty, op: op)
                } label: {
                    Text("\(score) \u{2192} 0")
                        .padding()
                        .frame(maxWidth: geometry.size.width * 0.55)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
