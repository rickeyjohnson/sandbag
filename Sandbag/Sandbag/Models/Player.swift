//
//  Player.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation

struct Player: Identifiable, Codable {
    let id: String
    var name: String
    var bid: Int?
    var booksWon: Int?
    var partnerId: String?
    var joinedAt: Date
}
