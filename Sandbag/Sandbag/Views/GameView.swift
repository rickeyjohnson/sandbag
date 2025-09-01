//
//  GameView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/26/25.
//

import SwiftUI

struct GameView: View {
    @StateObject var vm: GameViewModel
    let playerId: String
    let isHost: Bool
    
    var body: some View {
        VStack {
            if let game = vm.game {
                if !game.isActive && game.winnerTeamId != nil {
                    WinnerView(game: game)
                } else if vm.isBidding {
                    BiddingView(vm: vm, playerId: playerId)
                } else if vm.isTeamConfirmation {
                    TeamConfirmationView(vm: vm, playerId: playerId)
                } else if vm.isPlaying {
                    PlayingView(vm: vm, playerId: playerId, isHost: isHost)
                } else if vm.isScoring {
                    ScoringView(vm: vm, playerId: playerId)
                } else if vm.isRoundFinished {
                    RoundSummaryView(vm: vm, playerId: playerId, isHost: isHost)
                } else {
                    Text("Waiting for game to start…")
                }
            } else {
                ProgressView("Loading game...")
            }
        }
        .padding()
        .alert(item: Binding(
            get: { vm.errorMessage.map { ErrorWrapper(message: $0) } },
            set: { _ in vm.errorMessage = nil })
        ) { wrapper in
            Alert(title: Text("Error"), message: Text(wrapper.message), dismissButton: .default(Text("OK")))
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ErrorWrapper: Identifiable {
    var id: String = UUID().uuidString
    var message: String
}
