//
//  Round.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation

enum RoundPhase: String, Codable {
    case bidding
    case teamConfirmation
    case playing
    case scoring
    case scored
}

struct Round: Identifiable, Codable, Equatable {
    let id: String
    var bids: [String: Int] // playerID: bid
    var teamBids: [String: Int] // teamID: team bid
    var booksWon: [String: Int] // playerID: books
    var roundScore: [String: Int] // teamID: score
    var createdAt: Date
    var phase: RoundPhase
}
