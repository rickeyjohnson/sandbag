//
//  WinnerView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/31/25.
//

import SwiftUI

struct WinnerView: View {
    let game: Game
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: AppleDesign.spacing32) {
            Image(systemName: "crown.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            if let winner = game.winnerTeamId {
                Text("\(winner.capitalized) Team Wins!")
                    .font(.system(.largeTitle, weight: .bold))
                    .foregroundColor(winner == "red" ? .red : .blue)
            }
            
            Button("Back to Home") {
                dismiss()
            }
            .buttonStyle(ApplePrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, AppleDesign.spacing20)
        .background(AppleDesign.groupedBackground)
    }
}
