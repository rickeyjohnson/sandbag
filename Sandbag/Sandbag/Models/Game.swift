//
//  Game.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation

struct Game: Identifiable, Codable {
    let id: String
    var roomCode: String
    
    var players: [Player]       // all 4 players
    var teams: [Team]           // 2 teams
    var rounds: [Round]         // completed rounds
    var currentRound: Round?    // round in progress
    
    var targetScore: Int        // e.g. 500 points
    var isActive: Bool          // true if game is ongoing
    var winnerTeamId: String?   // set when someone reaches targetScore
}
