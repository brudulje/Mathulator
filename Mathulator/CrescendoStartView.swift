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
        VStack(spacing: 20) {
            Text("Start Crescendo Mode")
                .font(.title)
                .bold()
            
            // ✅ Use your custom operator selector instead of a Picker
            OperatorSelectionView(
                selectedOperator: $selectedOp,
                difficulty: $difficulty,
                highScores: highScores,
                onOperatorChange: { newOp in
                    selectedOp = newOp
                }
            )
            .frame(height: 60)
            
            Button("Start") {
                onStart(selectedOp)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }
}
