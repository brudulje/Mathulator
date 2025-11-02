//
//  AboutView.swift
//  RPNapp
//
//  Created by Joachim Seland Graff on 2025-08-09.
//


import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
                
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 20) {
                        Text("Mathulator helps you improve \nyour mathematics skills.")
                        Text("Providing an endless stream of maths problems covering all four arithmetic disciplines, this app will help you get better at addition, subtraction, multiplication and division.")
                             
                        Text("Choose your favorite discipline").font(.headline)
//                            .responsiveFont(.headline, weight: .bold) // Gets too large on large screens
                            
                             Text("Set your chosen discipline using the discipline selector at the bottom of the screen.")
                            .multilineTextAlignment(.leading)
                        

                        Text("Set the difficulty as you like it").font(.headline)
//                            .responsiveFont(.headline, weight: .bold) // Gets too large on large screens
                        Text("The difficulty of the problems can be adjusted using the slider just above the discipline selector. Problems ranging from basic to very difficult are available. The difficulty can be set from \(Int(DifficultyConfig.minDifficulty).description) to \(Int(DifficultyConfig.maxDifficulty).description).")
                            .multilineTextAlignment(.leading)

                        Text("Get trophies").font(.headline)
//                            .responsiveFont(.headline, weight: .bold) // Gets too large on large screens
                            
                        Text("The scoreboard will keep track of your maximum streak for each discipline and difficulty. Once you solve a problem and get a streak of 1, the background in the trophy overview goes blue. Reaching streaks of 5, 12, or 20 will earn you a new trophy.")
                            .multilineTextAlignment(.leading)
                        
                        Text("""
                        Version \(version) \nCreated by Joachim Seland Graff
                        """)
                        .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                .navigationTitle("About Mathulator")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    AboutView()
}
