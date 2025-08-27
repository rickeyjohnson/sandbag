//
//  FirestoreGameRepository.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/26/25.
//

import Foundation
import FirebaseFirestore

protocol GameListener {
    func cancel()
}

protocol GameRepository {
    func createGame(roomCode: String, players: [Player], teams: [Team], targetScore: Int) async throws -> Game
    func fetchGame(by id: String) async throws -> Game
    func updateGame(_ game: Game) async throws
    func deleteGame(by id: String) async throws
    
    func assignPlayerToTeam(gameId: String, playerId: String, team: TeamAssignment) async throws
    func startGame(gameId: String) async throws -> Game
    
    func addRound(to gameId: String, round: Round) async throws
    func endGame(_ gameId: String, winnerTeamId: String) async throws
    
    func listen(gameId: String, onChange: @escaping (Game) -> Void, onError: @escaping (Error) -> Void) -> GameListener
}

final class FirestoreGameRepository: GameRepository {
    private let db = Firestore.firestore()

    func createGame(roomCode: String, players: [Player], teams: [Team], targetScore: Int) async throws -> Game {
        let game = Game(
            id: UUID().uuidString,
            roomCode: roomCode,
            players: players,
            teams: teams,
            rounds: [],
            currentRound: nil,
            targetScore: targetScore,
            isActive: false,
            winnerTeamId: nil
        )

        try db.collection("games").document(game.id).setData(from: game)
        return game
    }

    func fetchGame(by id: String) async throws -> Game {
        let snap = try await db.collection("games").document(id).getDocument()
        guard let game = try snap.data(as: Game?.self) else {
            throw NSError(domain: "Game not found", code: 404)
        }
        return game
    }

    func updateGame(_ game: Game) async throws {
        try db.collection("games").document(game.id).setData(from: game, merge: true)
    }

    func deleteGame(by id: String) async throws {
        try await db.collection("games").document(id).delete()
    }

    func assignPlayerToTeam(gameId: String, playerId: String, team: TeamAssignment) async throws {
        let ref = db.collection("games").document(gameId)
        var game = try await ref.getDocument(as: Game.self)

        if let idx = game.players.firstIndex(where: { $0.id == playerId }) {
            game.players[idx].team = team
        }

        try ref.setData(from: game, merge: true)
    }

    func addRound(to gameId: String, round: Round) async throws {
        let ref = db.collection("games").document(gameId)
        var game = try await ref.getDocument(as: Game.self)

        game.rounds.append(round)
        game.currentRound = nil

        try ref.setData(from: game, merge: true)
    }

    func startGame(gameId: String) async throws -> Game {
        let ref = db.collection("games").document(gameId)
        var game = try await ref.getDocument(as: Game.self)

        let redCount = game.players.filter { $0.team == .red }.count
        let blueCount = game.players.filter { $0.team == .blue }.count

        guard redCount == 2 && blueCount == 2 else {
            throw NSError(domain: "Teams not ready", code: 400)
        }

        game.isActive = true
        try ref.setData(from: game, merge: true)

        return game
    }

    func endGame(_ gameId: String, winnerTeamId: String) async throws {
        let ref = db.collection("games").document(gameId)
        var game = try await ref.getDocument(as: Game.self)

        game.isActive = false
        game.winnerTeamId = winnerTeamId

        try ref.setData(from: game, merge: true)
    }

    func listen(gameId: String,
                onChange: @escaping (Game) -> Void,
                onError: @escaping (Error) -> Void) -> GameListener {
        let listener = db.collection("games").document(gameId)
            .addSnapshotListener { snapshot, error in
                if let error = error { onError(error); return }
                guard let snapshot, let game = try? snapshot.data(as: Game.self) else { return }
                onChange(game)
            }

        return FirestoreGameListener(listener: listener)
    }
}

final class FirestoreGameListener: GameListener {
    private var handle: ListenerRegistration?
    init(listener: ListenerRegistration) { self.handle = listener }
    func cancel() { handle?.remove(); handle = nil }
}
