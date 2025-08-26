//
//  RoomRepository.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation

protocol RoomListener {
    func cancel()
}

protocol RoomRepository {
    func createRoom(host: Player, code: String) async throws -> Room
    func joinRoom(code: String, player: Player) async throws -> Room
    func leaveRoom(roomId: String, playerId: String) async throws
    func setPartner(roomId: String, playerId: String, partnerId: String?) async throws
    
    func listen(roomId: String, onChange: @escaping (Room) -> Void, onError: @escaping (Error) -> Void) -> RoomListener
    func isCodeAvailable(_ code: String) async throws -> Bool
    
    func assignPlayerToTeam(roomId: String, playerId: String, team: TeamAssignment) async throws
    func startGame(from room: Room, targetScore: Int) async throws -> Game
}
