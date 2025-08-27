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
    
    func attachListener(gameId: String) {
        detachListener()
        listener = repository.listen(gameId: gameId, onChange: { [weak self] game in
            self?.game = game
        }, onError: { [weak self] error in
            self?.errorMessage = error.localizedDescription
        })
    }
    
    func detachListener() {
        listener?.cancel()
        listener = nil
    }
    
    func submitBid(playerId: String, bid: Int) {
        guard var currentGame = game else { return }
        
        if let idx = currentGame.players.firstIndex(where: { $0.id == playerId }) {
            currentGame.players[idx].bid = bid
        }
        
        Task {
            await runWithSpinner {
                try await repository.updateGame(currentGame)
            }
        }
    }
    
    func completeRound(booksWon: [String: Int]) {
        guard var currentGame = game else { return }
        
        for (playerId, books) in booksWon {
            if let idx = currentGame.players.firstIndex(where: { $0.id == playerId}) {
                currentGame.players[idx].booksWon = books
            }
        }
        
        let bidsDict: [String: Int] = currentGame.players.reduce(into: [:]) { result, player in
            result[player.id] = player.bid ?? 0
        }
        
        let roundScore: [String: Int] = [:]
        
        let round = Round(
            id: UUID().uuidString,
            bids: bidsDict,
            booksWon: booksWon,
            roundScore: roundScore,
            createdAt: Date()
        )
        
        Task {
            await runWithSpinner {
                try await repository.addRound(to: currentGame.id, round: round)
            }
        }
    }
    
    func endGame(winnerTeamId: String) {
        guard let gameId = game?.id else { return }
        Task {
            await runWithSpinner {
                try await repository.endGame(gameId, winnerTeamId: winnerTeamId)
            }
        }
    }
    
    private func runWithSpinner(_ work: () async throws -> Void) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await work()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
