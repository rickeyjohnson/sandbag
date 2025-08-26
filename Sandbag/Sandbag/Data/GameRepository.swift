//
//  GameRepository.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/25/25.
//

import Foundation

//protocol GameRepositoryProtocol {
//    func createGame(roomCode: String, players: [Player], teams: [Team], targetScore: Int) -> Game
//    func fetchGame(by id: String) -> Game?
//    func updateGame(_ game: Game)
//    func deleteGame(by id: String)
//    func assignPlayerToTeam(gameId: String, playerId: String, team: TeamAssignment) async throws
//    func startGame(gameId: String) async throws -> Game
//    
//    func addRound(to gameId: String, round: Round)
//    func endGame(_ gameId: String, winnerTeamId: String)
//}

final class GameRepository: GameRepositoryProtocol {
    private var games: [String: Game] = [:]
    
    // MARK: - CRUD
    
    func createGame(roomCode: String, players: [Player], teams: [Team], targetScore: Int) -> Game {
        let game = Game(
            id: UUID().uuidString,
            roomCode: roomCode,
            players: players,
            teams: teams,
            rounds: [],
            currentRound: nil,
            targetScore: targetScore,
            isActive: true,
            winnerTeamId: nil
        )
        
        games[game.id] = game
        return game
    }
    
    func fetchGame(by id: String) -> Game? { games[id] }
    
    func updateGame(_ game: Game) { games[game.id] = game }
    
    func deleteGame(by id: String) { games[id] = nil }
    
    func assignPlayerToTeam(gameId: String, playerId: String, team: TeamAssignment) async throws {
        guard var game = games[gameId],
              let index = game.players.firstIndex(where: { $0.id == playerId}) else { return }
        game.players[index].team = team
        games[gameId] = game
    }
    
    func startGame(gameId: String) async throws -> Game {
        guard var game = games[gameId] else { throw NSError(domain: "Game not found", code: 404)}
        let redCount = game.players.filter { $0.team == .red }.count
        let blueCount = game.players.filter { $0.team == .blue}.count
        
        guard redCount == 2 && blueCount == 2 else {
            throw NSError(domain: "Teams not ready", code: 400)
        }
        
        game.isActive = true
        games[gameId] = game
        return game
    }
    
    // MARK: - Game Logic
    
    func addRound(to gameId: String, round: Round) {
        guard var game = games[gameId] else { return }
        game.rounds.append(round)
        game.currentRound = nil
        updateGame(game)
    }
    
    func endGame(_ gameId: String, winnerTeamId: String) {
        guard var game = games[gameId] else { return }
        game.isActive = false
        game.winnerTeamId = winnerTeamId
        updateGame(game)
    }
}
