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
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                ZStack{
                    HStack{
                        Spacer()
                        Text("\u{1F3C6}")
                            .responsiveFont(.title)
                        Spacer()
                    }
                    HStack{
                        Spacer()
                        Button("Close") {
                            dismiss()
                        }
                    }
                
            }
                HStack{
                    //                    Text("Operator:").responsiveFont(.title2)
                    Spacer()
                    Spacer()
                    Text("\(op.rawValue)")
                        .frame(width: geometry.size.width * 0.21, height: geometry.size.width * 0.13, alignment: .center)
                        .responsiveFont(.title)
                        .background(ZStack{
                            Color.blue
                            Color.black.opacity(0.4)
                        })//.opacity(0.4) )
                        .foregroundColor(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    //                }
                    //                HStack {
                    
                    //                    Text("Difficulty:").responsiveFont(.title2)
                    Spacer()
                    Text("\(difficulty)")
                        .frame(width: geometry.size.width * 0.21, height: geometry.size.width * 0.13, alignment: .center)
                        .responsiveFont(.title2)
                    //                        .padding(4)
                        .foregroundColor(Color.black)
                        .background(ContentView.difficultyColor(for: Double(difficulty)))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Spacer()
                    Spacer()
                    }
                
                HStack{
                    let score = highScores.highScore(for: difficulty, op: op)
                    let symbols = HighScoresView.trophyText(for: score)
                    
                    //                    Text("Trophies:").responsiveFont(.title3)
                    Text(symbols)
                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width * 0.46 : geometry.size.width * 0.36, height: geometry.size.width * 0.17)
                        .responsiveFont(.title)
                        .padding(4)
                        .background(HighScoresView.highScoreBackgroundColor(for: score))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                
                //                Text("Operator: \(op.rawValue)")
                
                //                let score = highScores.highScore(for: difficulty, op: op)
                //                Text("Current Streak: \(score)")
                //                    .responsiveFont(.largeTitle)
                }
                
                HStack{
                let score = highScores.highScore(for: difficulty, op: op)
                    
                Text("Streak:").responsiveFont(.title3)
                Text("\(score)").responsiveFont(.title3)
            }
                Button(role: .destructive) {
                    highScores.reset(difficulty: difficulty, op: op)
                } label: {
                    Text("Reset Streak")
                        .padding()
                        .responsiveFont(.headline)
                        .frame(maxWidth: geometry.size.width * 0.55)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
        }
    }
}
