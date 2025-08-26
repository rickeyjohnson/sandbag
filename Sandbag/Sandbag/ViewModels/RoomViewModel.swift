//
//  RoomViewModel.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/24/25.
//

import Foundation
import Combine

@MainActor
class RoomViewModel: ObservableObject {
    // create a room with a unique 6-character code
    // join a room by code (cap at 4 players)
    // expose the current room + players to the UI (@Published)
    // Allow partner selection (pair two players)
    // Keep a live subscription to room changes (realtime updates)
    // Handle leaving room / cleaning up listeners
    // Surface loading & errors for the UI
    
    // MARK: - Published UI State
    @Published var room: Room?
    @Published var players: [Player] = []
    @Published var codeInput: String = ""
    @Published var nameInput: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var activeGame: Game?
    
    // MARK: - Dependencies
    private let repository: RoomRepository
    private var listener: RoomListener?
    
    private let playerIdKey = "localPlayerId"
    private(set) var localPlayerId: String
    
    // MARK: - Local
    var canStartGame: Bool {
        let red = players.filter { $0.team == .red }.count
        let blue = players.filter { $0.team == .blue }.count
        return red == 2 && blue == 2
    }
    let TARGET_SCORE = 500
    
    // MARK: - Init
    init(repository: RoomRepository) {
        self.repository = repository
        if let saved = UserDefaults.standard.string(forKey: playerIdKey) {
            self.localPlayerId = saved
        } else {
            let fresh = UUID().uuidString
            self.localPlayerId = fresh
            UserDefaults.standard.set(fresh, forKey: playerIdKey)
        }
    }
    
    // MARK: - Public API (called by Views)
    
    func createRoom() {
        Task {
            await runWithSpinner { [self] in
                // Validate name
                let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { throw VMError.input("Enter your name") }
                
                // Generate a unique 6-char code (retry if collision)
                let code = try await generateUniqueCode()
                
                let host = Player(id: localPlayerId,
                                  name: trimmed,
                                  partnerId: nil,
                                  joinedAt: Date(),
                                  team: .none)
                
                let newRoom = try await repository.createRoom(host: host, code: code)
                attachListener(roomId: newRoom.id)
            }
        }
    }
    
    func joinRoom() {
        Task {
            await runWithSpinner { [self] in
                let trimmedName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedCode = codeInput.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !trimmedName.isEmpty else { throw VMError.input("Enter you name") }
                guard trimmedCode.count == 6 else { throw VMError.input("Enter a 6-character code") }
                
                let me = Player (id: localPlayerId, name: trimmedName, partnerId: nil, joinedAt: Date(), team: .none)
                
                // join -> returns up-to-date room
                let updated = try await repository.joinRoom(code: trimmedCode, player: me)
                attachListener(roomId: updated.id)
            }
        }
    }
    
    func leaveRoom() {
        guard let roomId = room?.id else { return }
        Task {
            await runWithSpinner  { [self] in
                try await repository.leaveRoom(roomId: roomId, playerId: localPlayerId)
                detachListener()
                self.room = nil
                self.players = []
            }
        }
    }
    
    func pairWith(partnerId: String?) {
        // partnerId == nil to unpair
        guard let roomId = room?.id else { return }
        Task {
            await runWithSpinner { [self] in
                try await repository.setPartner(roomId: roomId, playerId: localPlayerId, partnerId: partnerId)
            }
        }
    }
    
    func assignTeam(team: TeamAssignment) {
        guard let roomId = room?.id else { return }
        Task {
            await runWithSpinner { [self] in
                try await repository.assignPlayerToTeam(roomId: roomId, playerId: localPlayerId, team: team)
            }
        }
    }
    
    func startGame() {
        guard let room else { return }
        Task {
            await runWithSpinner { [self] in
                let game = try await repository.startGame(from: room, targetScore: TARGET_SCORE)
                self.activeGame = game
            }
        }
    }
    
    // MARK: - Helpers
    
    private func attachListener(roomId: String) {
        // avoid multiple listeners
        detachListener()
        listener = repository.listen(roomId: roomId, onChange: { [weak self] room in
            guard let self else { return }
            self.room = room
            self.players = room.players.sorted(by: { $0.joinedAt < $1.joinedAt })
        }, onError: { [weak self] error in
            self?.errorMessage = error.localizedDescription
        })
    }
    
    private func detachListener() {
        listener?.cancel()
        listener = nil
    }
    
    private func generateUniqueCode() async throws -> String {
        // Try a few times (collisions are rare)
        for _ in 0..<5 {
            let code = Self.makeCode()
            if try await repository.isCodeAvailable(code) { return code }
        }
        throw VMError.general("Could not generate unique code. Try again.")
    }
    
    private static func makeCode() -> String {
        let alphabet = Array("ABCDEFGHJKMNPQRTUVWXYZ2346789")
        return String((0..<6).map{ _ in alphabet.randomElement()! })
    }
    
    private func runWithSpinner(_ work: @escaping () async throws -> Void) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await work()
            errorMessage = nil
        } catch let VMError.input(msg) {
            errorMessage = msg
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    enum VMError: Error {
        case input(String)
        case general(String)
    }
}
