//
//  GameViewModel.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/25/25.
//

import Foundation

@MainActor
class GameViewModel: ObservableObject {
    @Published var game: Game
    
    init(game: Game) {
        self.game = game
    }
    
    func submitBid(playerId: String, bid: Int) {
        if game.currentRound == nil {
            game.currentRound = Round(id: UUID().uuidString, bids: [:], booksWon: [:], roundScore: [:])
        }
        game.currentRound?.bids[playerId] = bid
    }
}
