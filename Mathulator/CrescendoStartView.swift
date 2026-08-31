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
    @State private var selectedLevel: CrescendoLevel = .hard
    
    var onStart: (Operator, CrescendoLevel) -> Void
    @ObservedObject var highScores: HighScores
    @Binding var difficulty: Double
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
//                Text("Select operator:").responsiveFont(.title3)
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
                
//                Text("Select difficulty level:").responsiveFont(.title3)
                HStack (spacing: 0){
                    ForEach(CrescendoLevel.allCases, id: \.self) { level in
                        Button(action: { selectedLevel = level }) {
                            Text(level.displayName)
                                .padding(8)
                                .responsiveFont(.body)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(selectedLevel == level ? Color.white.opacity(0.4) : Color.black.opacity(0.4))
                                .foregroundColor(selectedLevel == level ? Color.black : Color.white)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(height: 44)
                .background(Color.purple.opacity(0.6))
                .cornerRadius(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button("Start crescendo mode") {
                    onStart(selectedOp, selectedLevel)
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
