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
    func finishRound(gameId: String) async throws
    func startNextRound(gameId: String) async throws
    
    func assignPlayerToTeam(gameId: String, playerId: String, team: TeamAssignment) async throws
    func startGame(gameId: String) async throws -> Game
    func forfeitGame(gameId: String, quittingPlayerId: String) async throws
    
    func addRound(to gameId: String, round: Round) async throws
    func endGame(_ gameId: String, winnerTeamId: String) async throws
    
    func submitBid(gameId: String, playerId: String, bid: Int) async throws
    func confirmTeamBid(gameId: String, teamId: String, bid: Int, confirmedBy: String) async throws
    func submitBooks(gameId: String, playerId: String, books: Int) async throws
    func scoreRound(gameId: String, round: Round) async throws -> Game
    
    func listen(gameId: String, onChange: @escaping (Game) -> Void, onError: @escaping (Error) -> Void) -> GameListener
}

final class FirestoreGameRepository: GameRepository {
    private let db = Firestore.firestore()

    func createGame(roomCode: String, players: [Player], teams: [Team], targetScore: Int) async throws -> Game {
        let game = Game(
            roomCode: roomCode,
            players: players,
            teams: teams,
            targetScore: targetScore,
            teamTotals: ["red": 0, "blue": 0],
            playerTotals: Dictionary(uniqueKeysWithValues: players.map { ($0.id, 0) })
        )
        
        do {
            try db.collection("games").document(game.id).setData(from: game)
        } catch {
            print("Error creating game: \(error.localizedDescription)")
        }

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
    
    func finishRound(gameId: String) async throws {
        let ref = db.collection("games").document(gameId)
        var game = try await ref.getDocument(as: Game.self)
        
        guard var round = game.currentRound else {
            throw NSError(domain: "No active round", code: 400)
        }
        
        guard round.phase == .playing else {
            throw NSError(domain: "Round not in playing phase", code: 400)
        }
        
        round.phase = .scoring
        
        if let idx = game.rounds.indices.last {
            game.rounds[idx] = round
        }
        
        try ref.setData(from: game, merge: false)
    }
    
    func startNextRound(gameId: String) async throws {
        let ref = db.collection("games").document(gameId)
        var game = try await ref.getDocument(as: Game.self)

        guard let lastRound = game.rounds.last else {
            throw NSError(domain: "No previous round to continue from", code: 400)
        }
        
        guard lastRound.phase == .scored else {
            throw NSError(domain: "Last round not finished", code: 400)
        }

        let newRound = Round(
            id: UUID().uuidString,
            bids: [:],
            teamBids: [:],
            booksWon: [:],
            roundScore: [:],
            createdAt: Date(),
            phase: .bidding,
            teamConfirmers: [:]
        )

        game.rounds.append(newRound)

        try ref.setData(from: game, merge: false)
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

        try ref.setData(from: game, merge: true)
    }

    func startGame(gameId: String) async throws -> Game {
        let ref = db.collection("games").document(gameId)
        var game = try await ref.getDocument(as: Game.self)
        
        let newRound = Round(
                    id: UUID().uuidString,
                    bids: [:],
                    teamBids: [:],
                    booksWon: [:],
                    roundScore: [:],
                    createdAt: Date(),
                    phase: .bidding,
                    teamConfirmers: [:]
                )

        let redCount = game.players.filter { $0.team == .red }.count
        let blueCount = game.players.filter { $0.team == .blue }.count

        guard redCount == blueCount else {
            throw NSError(domain: "Teams not ready", code: 400)
        }

        game.isActive = true
        game.rounds = [newRound]
        try ref.setData(from: game, merge: true)

        return game
    }
    
    func forfeitGame(gameId: String, quittingPlayerId: String) async throws {
        let ref = db.collection("games").document(gameId)
        var game = try await ref.getDocument(as: Game.self)

        guard let quitter = game.players.first(where: { $0.id == quittingPlayerId }),
              let teamId = quitter.team?.rawValue else {
            throw NSError(domain: "Player or team not found", code: 400)
        }

        // Opposite team is winner
        let winnerTeamId = teamId == "red" ? "blue" : "red"
        game.isActive = false
        game.winnerTeamId = winnerTeamId

        try ref.setData(from: game, merge: true)
    }

    func endGame(_ gameId: String, winnerTeamId: String) async throws {
        let ref = db.collection("games").document(gameId)
        var game = try await ref.getDocument(as: Game.self)

        game.isActive = false
        game.winnerTeamId = winnerTeamId

        try ref.setData(from: game, merge: true)
    }
    
    func submitBid(gameId: String, playerId: String, bid: Int) async throws {
        let ref = db.collection("games").document(gameId)
        var game = try await ref.getDocument(as: Game.self)
        
        guard var round = game.currentRound else { throw NSError(domain: "No current round", code: 400) }
        round.bids[playerId] = bid
        
        if round.bids.count == game.players.count {
            round.phase = .teamConfirmation
            
            for team in game.teams {
                if round.teamConfirmers[team.id] == nil {
                    let teamPlayers = game.players.filter { $0.team?.rawValue == team.id }
                    if let chosen = teamPlayers.randomElement() {
                        round.teamConfirmers[team.id] = chosen.id
                    }
                }
            }
        }
        
        if let idx = game.rounds.indices.last {
           game.rounds[idx] = round
       }
        
        try ref.setData(from: game, merge: false)
    }
    
    func confirmTeamBid(gameId: String, teamId: String, bid: Int, confirmedBy: String) async throws {
        let ref = db.collection("games").document(gameId)
        var game = try await ref.getDocument(as: Game.self)
        
        guard var round = game.currentRound else { throw NSError(domain: "No active round", code: 400) }
        
        guard round.teamConfirmers[teamId] == confirmedBy else {
            throw NSError(domain: "Not authorized to confirm for this team", code: 403)
        }
        
        round.teamBids[teamId] = bid
        
        if round.teamBids.count == game.teams.count {
            round.phase = .playing
        }
        
        if let idx = game.rounds.indices.last {
            game.rounds[idx] = round
        }
        
        try ref.setData(from: game, merge: false)
    }
    
    func submitBooks(gameId: String, playerId: String, books: Int) async throws {
        let ref = db.collection("games").document(gameId)
        var game = try await ref.getDocument(as: Game.self)
        
        guard var round = game.currentRound else { throw NSError(domain: "No active round", code: 400) }
        round.booksWon[playerId] = books
        
        if let idx = game.rounds.indices.last {
            game.rounds[idx] = round
        }
        
        if round.booksWon.count == game.players.count {
            round.phase = .scoring
            let scoredGame = try await scoreRound(gameId: gameId, round: round)
            var finishedRound = scoredGame.rounds.last!
            finishedRound.phase = .scored
            
            var updatedGame = scoredGame
            updatedGame.rounds[updatedGame.rounds.count - 1] = finishedRound
            
            try ref.setData(from: updatedGame, merge: true)
            return
        }
        
        try ref.setData(from: game, merge: true)
    }
    
    func scoreRound(gameId: String, round: Round) async throws -> Game {
        let ref = db.collection("games").document(gameId)
        let game = try await ref.getDocument(as: Game.self)
        
        let (updatedRound, updatedGame) = calculateRoundScore(game: game, round: round)
        var gameCopy = updatedGame
        
        if let idx = gameCopy.rounds.indices.last {
            gameCopy.rounds[idx] = updatedRound
        }
        
        let winningTeams = gameCopy.teamTotals.filter { $0.value >= gameCopy.targetScore }.map { $0.key }
        
        if winningTeams.count == 1 {
            gameCopy.isActive = false
            gameCopy.winnerTeamId = winningTeams.first
        } else if winningTeams.count == 2 {
            let tieBreakerRound = Round(
                id: UUID().uuidString,
                bids: [:],
                teamBids: [:],
                booksWon: [:],
                roundScore: [:],
                createdAt: Date(),
                phase: .bidding,
                teamConfirmers: [:]
            )
            gameCopy.rounds.append(tieBreakerRound)
        }
        
        try ref.setData(from: gameCopy, merge: true)
        return gameCopy
    }
    
    private func calculateRoundScore(game: Game, round: Round) -> (Round, Game) {
        var updatedRound = round
        var updatedGame = game
        
        var roundScores: [String: Int] = [:]
        
        for team in [TeamAssignment.red, .blue] {
            let teamId = team.rawValue
            let teamPlayers = game.players.filter { $0.team == team }
            
            let bid = updatedRound.teamBids[teamId] ?? 0
            let books = teamPlayers.reduce(0) { $0 + (updatedRound.booksWon[$1.id] ?? 0) }
            
            var score = 0
            var bags = books - bid
            
            if books >= bid {
                score = (10 * bid) + bags
            } else {
                score = -(10 * bid)
                bags = 0
            }
            
            updatedGame.teamTotals[teamId, default: 0] += score
            
            if bags > 0 {
                let totalBags = (updatedRound.roundScore[teamId] ?? 0) + bags
                if totalBags >= 10 {
                    updatedGame.teamTotals[teamId, default: 0] -= 100
                }
                updatedRound.roundScore[teamId] = totalBags % 10
            }
            
            roundScores[teamId] = score
            
            for player in teamPlayers {
                let playerBooks = updatedRound.booksWon[player.id] ?? 0
                updatedGame.playerTotals[player.id, default: 0] += playerBooks
            }
        }
        
        updatedRound.roundScore = roundScores
        updatedRound.phase = .scored
        return (updatedRound, updatedGame)
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
