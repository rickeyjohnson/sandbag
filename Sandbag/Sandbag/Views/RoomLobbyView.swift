//
//  RoomLobbyView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/25/25.
//

import SwiftUI

struct RoomLobbyView: View {
    @ObservedObject var viewModel: RoomViewModel
    @State private var goToGame: Bool = false
    
    private var isHost: Bool {
        viewModel.room?.hostId == viewModel.localPlayerId
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if let room = viewModel.room {
                Text("Room Code: \(room.code)").font(.title3.bold())
                
                List(viewModel.players) { player in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text(player.team.rawValue.capitalized)
                            .foregroundColor(player.team == .red ? .red : (player.team == .blue ? .blue: .gray))
                        if player.id == viewModel.localPlayerId {
                            Text("You").foregroundStyle(.secondary).padding(.leading, 6)
                        }
                    }
                }
                
                HStack {
                    Button("Join Red") { viewModel.assignTeam(team: .red) }
                        .buttonStyle(.bordered)
                    
                    Button("Join Blue") { viewModel.assignTeam(team: .blue) }
                        .buttonStyle(.bordered)
                }
                
                if isHost {
                    Button("Start Game") {
                        viewModel.startGame()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.canStartGame)
                }
                
                Button("Leave Room", role: .destructive) {
                    viewModel.leaveRoom()
                }
                .padding(.top, 8)
                
                // Navigate when game is created
                NavigationLink("", isActive: $goToGame) {
                    if let game = viewModel.activeGame {
                        GameView(viewModel: GameViewModel(game: game))
                    }
                }
                .hidden()
            } else {
                Text("Room ended or unavaialable").foregroundStyle(.secondary)
            }
        }
        .padding()
        .navigationTitle("Room Lobby")
        .onChange(of: viewModel.activeGame) { _, newValue in
                goToGame = (newValue != nil)
        }
    }
}
