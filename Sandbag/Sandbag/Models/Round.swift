//
//  Round.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation

struct Round: Identifiable, Codable {
    let id: String
    var bids: [String: Int] // playerID: bid
    var booksWon: [String: Int] // playerID: books
    var roundScore: [String: Int] // teamID: score
}
