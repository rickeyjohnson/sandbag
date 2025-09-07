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
    @State private var targetScore = TARGET_SCORE
    
    private var isHost: Bool {
        viewModel.room?.hostId == localPlayerId
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with room code
            if let room = viewModel.room {
                headerSection(room: room)
                    .padding(.top, AppleDesign.spacing16)
                    .padding(.bottom, AppleDesign.spacing24)
            }
            
            ScrollView {
                LazyVStack(spacing: AppleDesign.spacing24) {
                    if let room = viewModel.room {
                        playersSection(room: room)
                        teamSelectionSection
                        if isHost {
                            hostSection
                        }
                        leaveSection
                    }
                }
                .padding(.horizontal, AppleDesign.spacing20)
                .padding(.bottom, AppleDesign.spacing32)
            }
        }
        .background(AppleDesign.groupedBackground)
        .navigationTitle("Room")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $goToGame) {
            if let game = activeGame {
                let gameRepo = FirestoreGameRepository()
                let gvm = GameViewModel(repository: gameRepo)
                GameView(vm: gvm, playerId: localPlayerId, isHost: isHost)
                    .onAppear {
                        gvm.game = game
                        gvm.listen(to: game.id)
                    }
            }
        }
        .onChange(of: viewModel.activeGame) { _, newGame in
            if let newGame {
                activeGame = newGame
                goToGame = true
            }
        }
    }
    
    private func headerSection(room: Room) -> some View {
        VStack(spacing: AppleDesign.spacing8) {
            Text("Room Code")
                .font(.system(.subheadline))
                .foregroundColor(AppleDesign.secondaryLabel)
            
            HStack(spacing: AppleDesign.spacing12) {
                Text(room.code)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(AppleDesign.label)
                
                Button(action: {
                    UIPasteboard.general.string = room.code
                }) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(.title2))
                        .foregroundColor(AppleDesign.accent)
                }
            }
        }
    }
    
    private func playersSection(room: Room) -> some View {
        VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
            Text("Players (\(room.players.count))")
                .font(.system(.headline, weight: .semibold))
                .foregroundColor(AppleDesign.label)
            
            VStack(spacing: 0) {
                ForEach(Array(room.players.enumerated()), id: \.element.id) { index, player in
                    PlayerRow(player: player, isCurrentPlayer: player.id == localPlayerId)
                    
                    if index < room.players.count - 1 {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
            .background(AppleDesign.background)
            .cornerRadius(AppleDesign.cornerRadius)
        }
    }
    
    private var teamSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
            Text("Choose Team")
                .font(.system(.headline, weight: .semibold))
                .foregroundColor(AppleDesign.label)
            
            HStack(spacing: AppleDesign.spacing12) {
                Button("Red Team") {
                    Task {
                        await viewModel.assignPlayerToTeam(playerId: localPlayerId, team: .red)
                    }
                }
                .buttonStyle(TeamButtonStyle(color: .red))
                
                Button("Blue Team") {
                    Task {
                        await viewModel.assignPlayerToTeam(playerId: localPlayerId, team: .blue)
                    }
                }
                .buttonStyle(TeamButtonStyle(color: .blue))
            }
        }
    }
    
    private var hostSection: some View {
        VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
            Text("Game Settings")
                .font(.system(.headline, weight: .semibold))
                .foregroundColor(AppleDesign.label)
            
            VStack(alignment: .leading, spacing: AppleDesign.spacing8) {
                Text("Target Score")
                    .font(.system(.subheadline))
                    .foregroundColor(AppleDesign.secondaryLabel)
                
                TextField("500", text: $targetScore)
                    .font(.system(.body, weight: .medium))
                    .keyboardType(.numberPad)
                    .padding(AppleDesign.spacing16)
                    .background(AppleDesign.background)
                    .cornerRadius(AppleDesign.cornerRadius)
                    .frame(maxWidth: 100)
            }
            
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
            .buttonStyle(ApplePrimaryButtonStyle())
            .disabled(!viewModel.canStartGame || Int(targetScore) == nil)
        }
    }
    
    private var leaveSection: some View {
        Button("Leave Room") {
            Task {
                await viewModel.leaveRoom(playerId: localPlayerId)
            }
        }
        .buttonStyle(ApplePrimaryButtonStyle(isDestructive: true))
    }
}

// MARK: - Supporting Views
struct PlayerRow: View {
    let player: Player
    let isCurrentPlayer: Bool
    
    var body: some View {
        HStack(spacing: AppleDesign.spacing12) {
            // Team indicator
            Circle()
                .fill(teamColor)
                .frame(width: 12, height: 12)
            
            // Player name
            Text(player.name)
                .font(.system(.body))
                .foregroundColor(AppleDesign.label)
            
            if isCurrentPlayer {
                Text("You")
                    .font(.system(.caption, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(AppleDesign.accent)
                    .cornerRadius(4)
            }
            
            Spacer()
            
            // Team name
            Text(teamDisplayName)
                .font(.system(.subheadline, weight: .medium))
                .foregroundColor(teamColor == .gray ? AppleDesign.secondaryLabel : teamColor)
        }
        .padding(.horizontal, AppleDesign.spacing16)
        .padding(.vertical, AppleDesign.spacing12)
    }
    
    private var teamColor: Color {
        switch player.team {
        case .red: return .red
        case .blue: return .blue
        default: return .gray
        }
    }
    
    private var teamDisplayName: String {
        switch player.team {
        case .red: return "Red"
        case .blue: return "Blue"
        default: return "No Team"
        }
    }
}

struct TeamButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, weight: .medium))
            .foregroundColor(color)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: AppleDesign.buttonRadius)
                    .fill(color.opacity(0.1))
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppleDesign.buttonRadius)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
