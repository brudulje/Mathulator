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
                Text("\(difficulty)")
                    .frame(width: geometry.size.width * 0.15, alignment: .center)
                    .font(.caption)
                    .padding(4)
                    .foregroundColor(Color.black)
                    .background(ContentView.difficultyColor(for: Double(difficulty)))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                Text("Operator: \(op.rawValue)")
                Text("\(op.rawValue)")
                
                    .frame(width: geometry.size.width * 0.1618, height: geometry.size.width * 0.1)
                    .font(.title)
                    .background(ZStack{
                        Color.blue
                        Color.black.opacity(0.4)
                    })//.opacity(0.4) )
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                let score = highScores.highScore(for: difficulty, op: op)
                Text("Current Streak: \(score)")
                    .font(.largeTitle)
                
                Button(role: .destructive) {
                    highScores.reset(difficulty: difficulty, op: op)
                } label: {
                    Text("Reset High Score")
                        .padding()
                        .frame(maxWidth: .infinity)
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
