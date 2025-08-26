//
//  GameView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/26/25.
//

import SwiftUI

struct GameView: View {
    @StateObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Target: \(viewModel.game.targetScore)")
                .font(.title3.bold())
            
            ForEach(viewModel.game.teams) { team in
                VStack(alignment: .leading) {
                    Text("\(team.id.capitalized) Team")
                        .font(.headline)
                    Text("Players: \(team.playerIds.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider().padding(.vertical, 8)
        }
    }
}
