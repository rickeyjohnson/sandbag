//
//  WinnerView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/31/25.
//

import SwiftUI

struct WinnerView: View {
    let game: Game
    
    var body: some View {
        VStack(spacing: 20) {
            if let winner = game.winnerTeamId {
                Text("\(winner.capitalized) Team Wins!")
                    .font(.largeTitle.bold())
                    .foregroundColor(winner == "red" ? .red : .blue)
            } else {
                Text("Game Over")
                    .font(.largeTitle.bold())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Final Scores:")
                    .font(.title2.bold())
                ForEach(game.teamTotals.keys.sorted(), id: \.self) { teamId in
                    Text("\(teamId.capitalized) Team: \(game.teamTotals[teamId] ?? 0)")
                }
            }
            
            NavigationLink("Back to Home", destination: HomeView())
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
        }
        .padding()
    }
}
