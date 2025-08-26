//
//  Team.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation

struct Team: Identifiable, Codable, Equatable {
    let id: String
    var playerIds: [String]
    var score: Int
    var bags: Int
}
