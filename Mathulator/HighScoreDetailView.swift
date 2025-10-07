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
                HStack{
                    Spacer()
                    Text("\u{1F3C6}")
                        .font(.title)
                    Spacer()
                }
                HStack{
                    Text("Operator:").font(.title2)
                    Text("\(op.rawValue)")
                        .frame(width: geometry.size.width * 0.21, height: geometry.size.width * 0.13, alignment: .center)
                        .font(.title)
                        .background(ZStack{
                            Color.blue
                            Color.black.opacity(0.4)
                        })//.opacity(0.4) )
                        .foregroundColor(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                HStack {
                    
                    Text("Difficulty:").font(.title2)
                    Text("\(difficulty)")
                        .frame(width: geometry.size.width * 0.21, height: geometry.size.width * 0.13, alignment: .center)
                        .font(.title2)
//                        .padding(4)
                        .foregroundColor(Color.black)
                        .background(ContentView.difficultyColor(for: Double(difficulty)))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                
                HStack{
                    let score = highScores.highScore(for: difficulty, op: op)
                    let symbols = HighScoresView.trophyText(for: score)
                    
                    Text("Streak:").font(.title3)
                    Text("\(score)").font(.title3)

                    Text("Trophies:").font(.title3)
                    Text(symbols)
                        .frame(width: geometry.size.width * 0.26, height: geometry.size.width * 0.13)
                        .font(.title3)
                        .padding(4)
                        .background(HighScoresView.highScoreBackgroundColor(for: score))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
//                Text("Operator: \(op.rawValue)")
                
//                let score = highScores.highScore(for: difficulty, op: op)
//                Text("Current Streak: \(score)")
//                    .font(.largeTitle)
                
                Button(role: .destructive) {
                    highScores.reset(difficulty: difficulty, op: op)
                } label: {
                    Text("Reset Streak")
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
