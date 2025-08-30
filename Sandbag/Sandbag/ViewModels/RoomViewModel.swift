//
//  RoomViewModel.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation
import Combine

@MainActor
class RoomViewModel: ObservableObject {
    // create a room with a unique 6-character code
    // join a room by code (cap at 4 players)
    // expose the current room + players to the UI (@Published)
    // Allow partner selection (pair two players)
    // Keep a live subscription to room changes (realtime updates)
    // Handle leaving room / cleaning up listeners
    // Surface loading & errors for the UI
    let TARGET_SCORE = 500
    
    // MARK: - Published UI State
    @Published var room: Room?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // MARK: - Dependencies
    private let repository: RoomRepository
    private var listener: RoomListener?
    
    @Published private(set) var localPlayerId: String?
    
    var canStartGame: Bool {
        guard let room = room else { return false }
        
        // Require exactly 4 players
        guard room.players.count >= 2 else { return false } // was 4 REVERT when deploying
        
        // Require that all players have a team assignment
        let allAssigned = room.players.allSatisfy { $0.team != nil }
        
        // Require that both teams have exactly 2 players
        let redCount = room.players.filter { $0.team == .red }.count
        let blueCount = room.players.filter { $0.team == .blue }.count
        
        return allAssigned && (redCount == blueCount)
    }
    
    
    // MARK: - Init
    init(repository: RoomRepository) {
        self.repository = repository
    }
    
    // MARK: - Public API (called by Views)
    
    func createRoom(playerName: String) async {
        isLoading = true
        do {
            let player = Player(id: UUID().uuidString, name: playerName, joinedAt: Date())
            self.localPlayerId = player.id
            let code = try await generateUniqueCode()
            let room = try await repository.createRoom(host: player, code: code)
            self.room = room
            listen(for: room.id)
        } catch {
            errorMessage = "Failed to create room: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func joinRoom(code: String, playerName: String) async {
        isLoading = true
        do {
            let player = Player(id: UUID().uuidString,
                                name: playerName,
                                joinedAt: Date())
            self.localPlayerId = player.id
            let room = try await repository.joinRoom(code: code, player: player)
            self.room = room
            listen(for: room.id)
        } catch {
            errorMessage = "Failed to join room: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func leaveRoom(playerId: String) async {
        guard let roomId = room?.id else { return }
        do {
            try await repository.leaveRoom(roomId: roomId, playerId: playerId)
            listener?.cancel()
            room = nil
        } catch {
            errorMessage = "Failed to leave room: \(error.localizedDescription)"
        }
    }
    
    func assignPlayerToTeam(playerId: String, team: TeamAssignment) async {
        guard let roomId = room?.id else { return }
        do {
            try await repository.assignPlayerToTeam(roomId: roomId, playerId: playerId, team: team)
        } catch {
            errorMessage = "Failed to assign team: \(error.localizedDescription)"
        }
    }
    
    func autoAssignTeams() async {
        guard let room = room else { return }
        for (index, player) in room.players.enumerated() {
            let team: TeamAssignment = (index % 2 == 0) ? .red : .blue
            await assignPlayerToTeam(playerId: player.id, team: team)
        }
    }
    
    func startGame(targetScore: Int) async -> Game? {
        guard let room = room else { return nil }
        do {
            let game = try await repository.startGame(from: room, targetScore: targetScore)
            return game
        } catch {
            errorMessage = "Failed to start game: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Firestore Listener
    private func listen(for roomId: String) {
        listener?.cancel()
        listener = repository.listen(
            roomId: roomId,
            onChange: { [weak self] updatedRoom in
                Task { @MainActor in
                    self?.room = updatedRoom
                }
            },
            onError: { [weak self] error in
                Task { @MainActor in
                    self?.errorMessage = error.localizedDescription
                }
            }
        )
    }
    
    // MARK: - Helpers
    
    private func generateUniqueCode() async throws -> String {
        // Try a few times (collisions are rare)
        for _ in 0..<5 {
            let code = Self.makeCode()
            if try await repository.isCodeAvailable(code) { return code }
        }
        throw VMError.general("Could not generate unique code. Try again.")
    }
    
    private static func makeCode() -> String {
        let alphabet = Array("ABCDEFGHJKMNPQRTUVWXYZ2346789")
        return String((0..<6).map{ _ in alphabet.randomElement()! })
    }
    
    enum VMError: Error {
        case general(String)
        case invalidInput(String)
    }
}
