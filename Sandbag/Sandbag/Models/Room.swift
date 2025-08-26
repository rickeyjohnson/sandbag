//
//  Room.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation

struct Room: Identifiable, Codable, Equatable {
    let id: String
    var code: String
    var hostId: String
    var players: [Player]
    var isGameActive: Bool
    var createdAt: Date
}
