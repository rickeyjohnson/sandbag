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
    
    var body: some View {
        VStack {
            if vm.isBidding {
                BiddingView(vm: vm, playerId: playerId)
            } else if vm.isTeamConfirmation {
                TeamConfirmationView(vm: vm, playerId: playerId)
            } else if vm.isPlaying {
                PlayingView(vm: vm)
            } else if vm.isScoring {
                ScoringView(vm: vm, playerId: playerId)
            } else if vm.isRoundFinished {
                RoundSummaryView(vm: vm)
            } else {
                Text("Waiting for game to start…")
            }
        }
        .alert(item: Binding(
            get: { vm.errorMessage.map { ErrorWrapper(message: $0) } },
            set: { _ in vm.errorMessage = nil })
        ) { wrapper in
            Alert(title: Text("Error"), message: Text(wrapper.message), dismissButton: .default(Text("OK")))
        }
    }
}

struct ErrorWrapper: Identifiable {
    var id: String = UUID().uuidString
    var message: String
}
