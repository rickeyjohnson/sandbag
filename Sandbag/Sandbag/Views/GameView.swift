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
        Group {
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
                    LoadingView(message: "Starting game...")
                }
            } else {
                LoadingView(message: "Loading game...")
            }
        }
        .background(AppleDesign.groupedBackground)
        .navigationBarBackButtonHidden(true)
        .alert(item: Binding(
            get: { vm.errorMessage.map { ErrorWrapper(message: $0) } },
            set: { _ in vm.errorMessage = nil })
        ) { wrapper in
            Alert(
                title: Text("Error"),
                message: Text(wrapper.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: AppleDesign.spacing20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.system(.body))
                .foregroundColor(AppleDesign.secondaryLabel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorWrapper: Identifiable {
    var id: String = UUID().uuidString
    var message: String
}
