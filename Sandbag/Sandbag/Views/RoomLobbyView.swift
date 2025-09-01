//
//  RoomLobbyView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/25/25.
//

import SwiftUI

struct RoomLobbyView: View {
    @ObservedObject var viewModel: RoomViewModel
    let localPlayerId: String
    @State private var goToGame: Bool = false
    @State private var activeGame: Game?
    @State private var targetScore = "500"
    
    private var isHost: Bool {
        viewModel.room?.hostId == localPlayerId
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if let room = viewModel.room {
                Text("Room Code: \(room.code)").font(.title3.bold())
                
                List(room.players) { player in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text(player.team?.rawValue.capitalized ?? "Unassigned")
                            .foregroundColor(player.team == .red ? .red : (player.team == .blue ? .blue : .gray))
                        if player.id == localPlayerId {
                            Text("You").foregroundStyle(.secondary).padding(.leading, 6)
                        }
                    }
                }
                
                HStack {
                    Button("Join Red") {
                        Task { await viewModel.assignPlayerToTeam(playerId: localPlayerId, team: .red) }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Join Blue") {
                        Task { await viewModel.assignPlayerToTeam(playerId: localPlayerId, team: .blue) }
                    }
                    .buttonStyle(.bordered)
                }
                
                if isHost {
                    Text("Set Target Score")
                        .font(.headline)

                    TextField("Target Score", text: $targetScore)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                        .multilineTextAlignment(.center)
                    
                    Button("Start Game") {
                        if let score = Int(targetScore), score > 0 {
                            Task {
                                if let game = await viewModel.startGame(targetScore: score) {
                                    activeGame = game
                                    goToGame = true
                                }
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.canStartGame || Int(targetScore) == nil)
                }
                
                Button("Leave Room", role: .destructive) {
                    Task { await viewModel.leaveRoom(playerId: localPlayerId) }
                }
                .padding(.top, 8)
                
                // Navigation to GameView
                NavigationLink("", isActive: $goToGame) {
                    if let game = activeGame {
                        let gameRepo = FirestoreGameRepository()
                        let gvm = GameViewModel(repository: gameRepo)
                        GameView(vm: gvm, playerId: localPlayerId, isHost: isHost)
                            .onAppear {
                                gvm.game = game
                                gvm.listen(to: game.id)
                            }
                    } else {
                        Text("Loading game...")
                    }
                }
                .hidden()
            } else {
                Text("Room ended or unavailable").foregroundStyle(.secondary)
            }
        }
        .padding()
        .navigationTitle("Room Lobby")
        .onChange(of: viewModel.activeGame) { _, newGame in
            // Non-host players move to game automatically
            if let newGame {
                activeGame = newGame
                goToGame = true
            }
        }
    }
}
