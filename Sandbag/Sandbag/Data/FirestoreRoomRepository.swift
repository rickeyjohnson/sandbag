//
//  FirestoreRoomRepository.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/26/25.
//

import Foundation
import FirebaseFirestore

protocol RoomListener {
    func cancel()
}

protocol RoomRepository {
    func createRoom(host: Player, code: String) async throws -> Room
    func joinRoom(code: String, player: Player) async throws -> Room
    func leaveRoom(roomId: String, playerId: String) async throws
    func setPartner(roomId: String, playerId: String, partnerId: String?) async throws
    
    func listen(roomId: String, onChange: @escaping (Room) -> Void, onError: @escaping (Error) -> Void) -> RoomListener
    func isCodeAvailable(_ code: String) async throws -> Bool
    
    func assignPlayerToTeam(roomId: String, playerId: String, team: TeamAssignment) async throws
    func startGame(from room: Room, targetScore: Int) async throws -> Game
}

final class FirestoreListenerHandle: RoomListener {
    private var handle: ListenerRegistration?
    init(listener: ListenerRegistration) { self.handle = listener }
    func cancel() { handle?.remove(); handle = nil }
}

final class FirestoreRoomRepository: RoomRepository {
    private let db = Firestore.firestore()

    func createRoom(host: Player, code: String) async throws -> Room {
        let room = Room(
            id: UUID().uuidString,
            code: code,
            hostId: host.id,
            players: [host],
            isGameActive: false,
            createdAt: Date(),
            currentGameId: nil // 🔹 Add this in Room model
        )
        try db.collection("rooms").document(room.id).setData(from: room)
        return room
    }

    func joinRoom(code: String, player: Player) async throws -> Room {
        guard let snap = try await db.collection("rooms")
            .whereField("code", isEqualTo: code)
            .getDocuments().documents.first else {
            throw NSError(domain: "Room not found", code: 404)
        }

        var room = try snap.data(as: Room.self)
        guard room.players.count < 4 else {
            throw NSError(domain: "Room full", code: 409)
        }

        // Avoid duplicates
        if !room.players.contains(where: { $0.id == player.id }) {
            room.players.append(player)
        }

        try snap.reference.setData(from: room)
        return room
    }

    func leaveRoom(roomId: String, playerId: String) async throws {
        let ref = db.collection("rooms").document(roomId)
        var room = try await ref.getDocument(as: Room.self)
        
        if room.hostId == playerId {
            try? await ref.delete()
        } else {
            room.players.removeAll { $0.id == playerId }
            try? ref.setData(from: room, merge: true)
        }
    }

    func setPartner(roomId: String, playerId: String, partnerId: String?) async throws {
        let ref = db.collection("rooms").document(roomId)
        var room = try await ref.getDocument(as: Room.self)

        room.players = room.players.map { player in
            var copy = player
            if player.id == playerId { copy.partnerId = partnerId }
            if player.id == partnerId { copy.partnerId = playerId }
            if partnerId == nil, copy.partnerId == playerId { copy.partnerId = nil }
            return copy
        }

        try ref.setData(from: room)
    }

    func listen(roomId: String,
                onChange: @escaping (Room) -> Void,
                onError: @escaping (Error) -> Void) -> RoomListener {
        let listener = db.collection("rooms").document(roomId)
            .addSnapshotListener { snapshot, error in
                if let error = error { onError(error); return }
                guard let snapshot, let room = try? snapshot.data(as: Room.self) else { return }
                onChange(room)
            }
        return FirestoreListenerHandle(listener: listener)
    }

    func isCodeAvailable(_ code: String) async throws -> Bool {
        let docs = try await db.collection("rooms")
            .whereField("code", isEqualTo: code)
            .getDocuments()
        return docs.isEmpty
    }

    func assignPlayerToTeam(roomId: String, playerId: String, team: TeamAssignment) async throws {
        let ref = db.collection("rooms").document(roomId)
        var room = try await ref.getDocument(as: Room.self)

        if let idx = room.players.firstIndex(where: { $0.id == playerId }) {
            room.players[idx].team = team
        }

        try ref.setData(from: room)
    }

    func startGame(from room: Room, targetScore: Int) async throws -> Game {
        // Validate teams
        let red = room.players.filter { $0.team == .red }
        let blue = room.players.filter { $0.team == .blue }
        let unnassigned = room.players.filter { $0.team == nil }
        
        guard unnassigned.isEmpty else {
            throw NSError(domain: "All players must join a team", code: 400)
        }
        
        guard red.count == blue.count else {
            throw NSError(domain: "Teams not ready", code: 400)
        }

        // Create teams
        let teams = [
            Team(id: "red", assignment: .red, score: 0, bags: 0),
            Team(id: "blue", assignment: .blue, score: 0, bags: 0)
        ]
        
        // Create round
        let firstRound = Round(
            id: UUID().uuidString,
            bids: [:],
            teamBids: [:],
            booksWon: [:],
            roundScore: [:],
            createdAt: Date(),
            phase: .bidding,
            teamConfirmers: [:]
        )

        // Create game
        let game = Game(
            id: UUID().uuidString,
            roomCode: room.code,
            players: room.players,
            teams: teams,
            rounds: [firstRound],
            targetScore: targetScore,
            isActive: true,
            winnerTeamId: nil
        )

        // Save game
        try db.collection("games").document(game.id).setData(from: game)

        // Update room
        var updatedRoom = room
        updatedRoom.isGameActive = true
        updatedRoom.currentGameId = game.id
        updatedRoom.activeGame = game
        
        try db.collection("rooms").document(room.id).setData(from: updatedRoom)

        return game
    }
}

