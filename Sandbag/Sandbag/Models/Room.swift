//
//  Room.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation

struct Room: Identifiable, Codable {
    let id: String
    var code: String
    var players: [Player]
    var teams: [Team]
    var rounds: [Round]
    var isGameActive: Bool
}
