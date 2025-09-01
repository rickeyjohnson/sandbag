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
    let isHost: Bool
    
    var body: some View {
        VStack {
            Text("Game in progress…")
                .font(.headline)

            if isHost {
                Button("Finish Round") {
                    Task { await vm.finishRound() }
                }
                .padding(.top, 12)
            } else {
                Text("Waiting for host to finish the round…")
                .foregroundColor(.secondary)
                .padding(.top, 12)
            }
        }
        .padding()
    }
}
