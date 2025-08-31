//
//  PlayingView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/28/25.
//

import SwiftUI

struct PlayingView: View {
    @ObservedObject var vm: GameViewModel
    let playerId: String
    
    var body: some View {
        VStack {
            Text("Game in progress…")
                .font(.headline)
            
            // TODO: - Add isHost attribute to button
            Button("Finish Round") {
                Task { await vm.finishRound() }
            }
            .padding(.top, 12)
            
            Button("Quit Game", role: .destructive) {
                Task { await vm.forfeitGame(playerId: playerId) }
            }
            .padding(.top, 12)
        }
        .padding()
    }
}
