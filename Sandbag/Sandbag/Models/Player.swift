//
//  Player.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation

enum TeamAssignment: String, Codable {
    case none
    case red
    case blue
}

struct Player: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var bid: Int?
    var booksWon: Int?
    var partnerId: String?
    var joinedAt: Date
    var team: TeamAssignment?
}
