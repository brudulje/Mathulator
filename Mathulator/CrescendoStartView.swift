//
//  CrescendoStartView.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2025-11-08.
//

import SwiftUI

struct CrescendoStartView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedOp: Operator = .add
    
    var onStart: (Operator) -> Void
    @ObservedObject var highScores: HighScores
    @Binding var difficulty: Double
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select operator:").responsiveFont(.title3)
                OperatorSelectionView(
                    selectedOperator: $selectedOp,
                    difficulty: $difficulty,
                    highScores: highScores,
                    onOperatorChange: { newOp in
                        selectedOp = newOp
                    }
                )
                .frame(height: 60)
                .background(Color.purple.opacity(0.6))
                .cornerRadius(15)
                
                Button("Start crescendo mode") {
                    onStart(selectedOp)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .navigationTitle("Crescendo settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}
