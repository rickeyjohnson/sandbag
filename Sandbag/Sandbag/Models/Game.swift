//
//  Game.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation

struct Game: Identifiable, Codable, Equatable {
    let id: String
    var roomCode: String
    
    var players: [Player]       // all 4 players
    var teams: [Team]           // 2 teams
    var rounds: [Round]         // completed rounds
    var currentRound: Round? {
        rounds.last
    }    // round in progress
    
    var targetScore: Int        // e.g. 500 points
    var isActive: Bool          // true if game is ongoing
    var winnerTeamId: String?   // set when someone reaches targetScore
    
    var teamTotals: [String: Int] // teamID: total score
    var playerTotals: [String: Int] // playerID: total score
    
    init(
        id: String = UUID().uuidString,
        roomCode: String,
        players: [Player],
        teams: [Team],
        rounds: [Round] = [],
        targetScore: Int,
        isActive: Bool = false,
        winnerTeamId: String? = nil,
        teamTotals: [String: Int] = ["red": 0, "blue": 0],
        playerTotals: [String: Int] = [:]
    ) {
        self.id = id
        self.roomCode = roomCode
        self.players = players
        self.teams = teams
        self.rounds = rounds
        self.targetScore = targetScore
        self.isActive = isActive
        self.winnerTeamId = winnerTeamId
        self.teamTotals = teamTotals
        self.playerTotals = playerTotals
    }
}
