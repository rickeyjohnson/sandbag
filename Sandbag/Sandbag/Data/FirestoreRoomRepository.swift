//
//  FirestoreRoomRepository.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/26/25.
//

import Foundation
import FirebaseFirestore

final class FirestoreRoomRepository: RoomRepository {
    private let db = Firestore.firestore()
    
    func createRoom(host: Player, code: String) async throws -> Room {
        let room = Room(
            id: UUID().uuidString,
            code: code,
            hostId: host.id,
            players: [host],
            isGameActive: false,
            createdAt: Date()
        )
        
        try db.collection("rooms").document(room.id).setData(from: room)
        return room
    }
    
    func joinRoom(code: String, player: Player) async throws -> Room {
        guard let snap = try await db.collection("rooms").whereField("code", isEqualTo: code).getDocuments().documents.first else {
            throw NSError(domain: "Room not found", code: 404)
        }
        let doc = snap.reference
        var room = try snap.data(as: Room.self)
        
        guard room.players.count < 4 else {
            throw NSError(domain: "Room full", code: 409)
        }
        
        room.players.append(player)
        try doc.setData(from: room)
        return room
    }
    
    func leaveRoom(roomId: String, playerId: String) async throws {
        let ref = db.collection("rooms").document(roomId)
        var room = try await ref.getDocument(as: Room.self)
        room.players.removeAll { $0.id == playerId }
        try ref.setData(from: room)
    }
    
    func setPartner(roomId: String, playerId: String, partnerId: String?) async throws {
        let ref = db.collection("rooms").document(roomId)
        var room = try await ref.getDocument(as: Room.self)
        room.players = room.players.map { player in
            var copy = player
            if player.id == playerId { copy.partnerId = partnerId }
            if player.id == partnerId { copy.partnerId = playerId }
            if partnerId == nil, copy.partnerId == playerId { copy.partnerId = nil }
            return copy
        }
        
        try ref.setData(from: room)
    }
}
