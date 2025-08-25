//
//  Team.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation

struct Team: Identifiable, Codable {
    let id: String
    var players: [String] // store player IDs
    var score: Int
    var bags: Int
}
