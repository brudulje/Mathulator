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
    let newRecordSet: Bool
    let oldRecord: Int?
    let newRecord: Int?
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Text("Operator: \(selectedOperator.rawValue)")
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

                Button("Continue") {
                    onDismiss()
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Crescendo done")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        onDismiss()
                    }
                }
            }
            .padding()
        }
    }
}
