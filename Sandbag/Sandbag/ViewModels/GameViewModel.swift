//
//  GameViewModel.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/25/25.
//

import Foundation

@MainActor
class GameViewModel: ObservableObject {
    @Published var game: Game?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: GameRepository
    private var listener: GameListener?
    
    init(repository: GameRepository) {
        self.repository = repository
    }
    
    // MARK: - Round Phases
    
    var currentPhase: RoundPhase? { game?.currentRound?.phase }
    
    var isBidding: Bool { currentPhase == .bidding }
    var isTeamConfirmation: Bool { currentPhase == .teamConfirmation }
    var isPlaying: Bool { currentPhase == .playing }
    var isScoring: Bool { currentPhase == .scoring }
    var isRoundFinished: Bool { currentPhase == .scored }
    
    // MARK: - Listeners
    
    func listen(to gameId: String) {
        listener?.cancel()
        listener = repository.listen(
            gameId: gameId,
            onChange: { [weak self] updatedGame in
                Task { @MainActor in
                    self?.game = updatedGame
                }
            },
            onError: { [weak self] error in
                Task { @MainActor in
                    self?.errorMessage = error.localizedDescription
                }
            })
    }
    
    func stopListening() {
        listener?.cancel()
        listener = nil
    }
    
    // MARK: - Game Flow
    
    func startGame() async {
        guard let gameId = game?.id else { return }
        isLoading = true
        do {
            let updated = try await repository.startGame(gameId: gameId)
            self.game = updated
        } catch {
            errorMessage = "Failed to start game: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func endGame(winnerTeamId: String) async {
        guard let gameId = game?.id else { return }
        do {
            try await repository.endGame(gameId, winnerTeamId: winnerTeamId)
        } catch {
            errorMessage = "Failed to end game: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Round Flow
    func submitBid(playerId: String, bid: Int) async {
        guard let gameId = game?.id else { return }
        do {
            try await repository.submitBid(gameId: gameId, playerId: playerId, bid: bid)
        } catch {
            errorMessage = "Failed to submit bid: \(error.localizedDescription)"
        }
    }
    
    func confirmTeamBid(teamId: String, bid: Int, comfirmedBy: String) async {
        guard let gameId = game?.id else { return }
        do {
            try await repository.confirmTeamBid(gameId: gameId, teamId: teamId, bid: bid, confirmedBy: comfirmedBy)
        } catch {
            errorMessage = "Failed to confirm team bid: \(error.localizedDescription)"
        }
    }
    
    func submitBooks(playerId: String, books: Int) async {
        guard let gameId = game?.id else { return }
        do {
            try await repository.submitBooks(gameId: gameId, playerId: playerId, books: books)
        } catch {
            errorMessage = "Failed to submit books: \(error.localizedDescription)"
        }
    }
    
    func scoreRound(round: Round) async {
        guard let gameId = game?.id else { return }
        do {
            let updated = try await repository.scoreRound(gameId: gameId, round: round)
            self.game = updated
        } catch {
            errorMessage = "Failed to score round: \(error.localizedDescription)"
        }
    }
    
    func finishRound() async {
        guard let gameId = game?.id else { return }
        do {
            try await repository.finishRound(gameId: gameId)
        } catch {
            errorMessage = "Failed to finish round: \(error.localizedDescription)"
        }
    }
    
    func startNextRound() async {
        guard let gameId = game?.id else { return }
        do {
            try await repository.startNextRound(gameId: gameId)
        } catch {
            errorMessage = "Failed to start next round: \(error.localizedDescription)"
        }
    }
    
    func forfeitGame(playerId: String) async {
        guard let gameId = game?.id else { return }
        do {
            try await repository.forfeitGame(gameId: gameId, quittingPlayerId: playerId)
        } catch {
            errorMessage = "Failed to forfeit: \(error.localizedDescription)"
        }
    }
    
    func assignPlayerToTeam(playerId: String, teamId: TeamAssignment) async {
        guard let gameId = game?.id else { return }
        do {
            try await repository.assignPlayerToTeam(gameId: gameId, playerId: playerId, team: teamId)
        } catch {
            errorMessage = "Failed to assign player to team: \(error.localizedDescription)"
        }
    }
}
