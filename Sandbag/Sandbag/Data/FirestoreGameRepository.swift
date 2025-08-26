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

protocol GameRepositoryProtocol {
    func createGame(roomCode: String, players: [Player], teams: [Team], targetScore: Int) -> Game
    func fetchGame(by id: String) -> Game?
    func updateGame(_ game: Game)
    func deleteGame(by id: String)
    
    func assignPlayerToTeam(gameId: String, playerId: String, team: TeamAssignment) async throws
    func startGame(gameId: String) async throws -> Game
    
    func addRound(to gameId: String, round: Round)
    func endGame(_ gameId: String, winnerTeamId: String)
    
    func listen(gameId: String, onChange: @escaping (Game) -> Void, onError: @escaping (Error) -> Void) -> GameListener
}

final class FirestoreGameRepository: GameRepositoryProtocol {
    private let db = Firestore.firestore()
    
    func createGame(roomCode: String, players: [Player], teams: [Team], targetScore: Int) -> Game {
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
        
        do  {
            try db.collection("games").document(game.id).setData(from: game)
        } catch {
            print("Error creating game: \(error.localizedDescription)")
        }
        
        return game
    }
    
    func fetchGame(by id: String) -> Game? {
        return nil
    }
    
    func updateGame(_ game: Game) {
        do {
            try db.collection("games").document(game.id).setData(from: game, merge: true)
        } catch {
            print("Error updating game: \(error.localizedDescription)")
        }
    }
    
    func assignPlayerToTeam(gameId: String, playerId: String, team: TeamAssignment) async throws {
        let ref = db.collection("games").document(gameId)
        
        let snapshot = try await ref.getDocument()
        guard var game = try snapshot.data(as: Game?.self) else {
            throw NSError(domain: "Game not found", code: 404)
        }
        // update player
        if let idx = game.players.firstIndex(where: { $0.id == playerId }) {
            game.players[idx].team = team
        }
        
        try ref.setData(from: game, merge: true)
    }
    
    func addRound(to gameId: String, round: Round) {
        let ref = db.collection("games").document(gameId)
        
        Task {
            do {
                let snapshot = try await ref.getDocument()
                guard var game = try snapshot.data(as: Game?.self) else { return }
                
                game.rounds.append(round)
                game.currentRound = nil
                
                try ref.setData(from: game, merge: true)
            } catch {
                print("Error adding round: \(error.localizedDescription)")
            }
        }
    }
    
    func endGame(_ gameId: String, winnerTeamId: String) {
        let ref = db.collection("games").document(gameId)
        
        Task {
            do {
                let snapshot = try await ref.getDocument()
                guard var game = try snapshot.data(as: Game?.self) else { return }
                
                game.isActive = false
                game.winnerTeamId = winnerTeamId
                
                try ref.setData(from: game, merge: true)
            } catch {
                print("Error ending game: \(error.localizedDescription)")
            }
        }
    }
    
    func listen(gameId: String, onChange: @escaping (Game) -> Void, onError: @escaping (any Error) -> Void) -> any GameListener {
        let listener = db.collection("games").document(gameId)
            .addSnapshotListener { snapshot, error in
                if let error = error { onError(error); return }
                guard let snapshot, let room = try? snapshot.data(as: Game.self) else { return }
                onChange(room)
        }
        
        return FirestoreGameListener(listener: listener)
    }
}

final class FirestoreGameListener: GameListener {
    private var handle: ListenerRegistration?
    
    init(listener: ListenerRegistration?) {
        self.handle = listener
    }
    
    func cancel() {
        handle?.remove()
        handle = nil
    }
}
