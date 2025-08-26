//
//  MockRoomRespository.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation

final class MockRoomListener: RoomListener {
    private let onCancel: () -> Void
    
    init(onCancel: @escaping () -> Void) {
        self.onCancel = onCancel
    }
    
    func cancel() { onCancel() }
}

final class MockRoomRespository: RoomRepository {
    private var roomsById: [String: Room] = [:]
    private var listeners: [String: [(Room) -> Void]] = [:]
    
    func createRoom(host: Player, code: String) async throws -> Room {
        let room = Room(id: UUID().uuidString,
                        code: code,
                        hostId: host.id,
                        players: [host],
                        isGameActive: false,
                        createdAt: Date())
        roomsById[room.id] = room
        broadcast(room)
        return room
    }
    
    func joinRoom(code: String, player: Player) async throws -> Room {
        guard var room = roomsById.values.first(where: { $0.code == code }) else {
            throw NSError(domain: "Mock", code: 404, userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        
        guard room.players.count < 4 else {
            throw NSError(domain: "Mock", code: 409, userInfo: [NSLocalizedDescriptionKey: "Room full"])
        }
        
        room.players.append(player)
        roomsById[room.id] = room
        broadcast(room)
        return room
    }
    
    func leaveRoom(roomId: String, playerId: String) async throws {
        guard var room = roomsById[roomId] else { return }
        room.players.removeAll { $0.id == playerId }
        
        // If host leaves and others remain, you could reassign host.
        if room.hostId == playerId, let newHost = room.players.first?.id {
            room.hostId = newHost
        }
        roomsById[roomId] = room
        broadcast(room)
    }
    
    func setPartner(roomId: String, playerId: String, partnerId: String?) async throws {
        guard var room = roomsById[roomId] else { return }
        room.players = room.players.map { player in
            var copy = player
            if player.id == playerId { copy.partnerId = partnerId }
            if player.id == partnerId { copy.partnerId = playerId } // mirror pairing
            
            // Optional: if setting nil, also clear the counterpart
            if partnerId == nil, copy.partnerId == playerId { copy.partnerId = nil }
            return copy
        }
        
        roomsById[roomId] = room
        broadcast(room)
    }
    
    func listen(roomId: String, onChange: @escaping (Room) -> Void, onError: @escaping (Error) -> Void) -> RoomListener {
        listeners[roomId, default: []].append(onChange)
        if let room = roomsById[roomId] { onChange(room) } // push current
        return MockRoomListener { [weak self] in
            self?.listeners[roomId]?.removeAll()
        }
    }
    
    func assignPlayerToTeam(roomId: String, playerId: String, team: TeamAssignment) async throws {
        guard var room = roomsById[roomId] else { return }
        room.players = room.players.map { player in
            var copy = player
            if player.id == playerId {
                copy.team = team
            }
            return copy
        }
        roomsById[roomId] = room
        broadcast(room)
    }
    
    func startGame(from room: Room, targetScore: Int) async throws -> Game {
        guard room.players.count == 4 else {
            throw NSError(domain: "Mock", code: 400, userInfo: [NSLocalizedDescriptionKey: "Need 4 players"])
        }
        let teams = [
            Team(id: "red", playerIds: room.players.filter { $0.team == .red }.map { $0.id }, score: 0, bags: 0),
            Team(id: "blue", playerIds: room.players.filter { $0.team == .blue }.map { $0.id }, score: 0, bags: 0)
        ]
        return Game(
            id: UUID().uuidString,
            roomCode: room.code,
            players: room.players,
            teams: teams,
            rounds: [],
            currentRound: nil,
            targetScore: targetScore,
            isActive: true,
            winnerTeamId: nil
        )
    }
    
    func isCodeAvailable(_ code: String) async throws -> Bool {
        !roomsById.values.contains(where: { $0.code == code })
    }
    
    private func broadcast(_ room: Room) {
        listeners[room.id]?.forEach { $0(room) }
    }
}
