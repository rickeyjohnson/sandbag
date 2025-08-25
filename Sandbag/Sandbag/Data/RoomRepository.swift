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
    
    // Called once; emits updates as the room changes (realtime)
    func listen(roomId: String, onChange: @escaping (Room) -> Void, onError: @escaping (Error) -> Void) -> RoomListener
    
    // Check code uniqueness if your backend supports it
    func isCodeAvailable(_ code: String) async throws -> Bool
    
}
