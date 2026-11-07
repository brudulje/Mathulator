//
//  CrescendoSummaryView.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-11-09.
//

import SwiftUI

struct CrescendoSummaryView: View {
    let difficulty: Int
    let selectedOperator: Operator
    let level: CrescendoLevel
    let newRecordSet: Bool
    let oldRecord: Int?
    let newRecord: Int?
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    var onStartCrescendo: (Operator, CrescendoLevel) -> Void = { _, _ in }
    @State private var showStartAgain = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Text("Operator: \(selectedOperator.rawValue)")
                Text("Level: \(level.displayName)")
                Text("Difficulty reached: \(difficulty)")
                if newRecordSet {
                                Text("🎉 New Record!")
                                    .font(.title2).bold()
                                Text("Old Record: \(oldRecord ?? 0)")
                                Text("New Record: \(newRecord ?? 0)")
                            } else {
                                Text("No new record this time.")
                                Text("Your best: \(newRecord ?? 0)")
                            }

                Button("Play again") {
                    showStartAgain = true
                }
                .buttonStyle(.bordered)
                
                Button("Done") {
                    onDismiss()
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Crescendo mode done")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .sheet(isPresented: $showStartAgain) {
                let start = CrescendoStartView(
                    onStart: { op, lvl in
                        onStartCrescendo(op, lvl)
                        showStartAgain = false
                    },
                    highScores: HighScores(),
                    difficulty: .constant(Double(difficulty))
                )
                if #available(iOS 16.0, *) {
                    start
                        .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] : [.medium])
                        .presentationDragIndicator(.visible)
                } else {
                    start
                }
            }
//                    .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] :[.medium])
//                    .presentationDragIndicator(.visible)
               
            }
        }
    }
//}

