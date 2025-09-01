//
//  HomeView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/25/25.
//

import SwiftUI

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: RoomViewModel
    @State private var joinCode: String = ""
    @State private var playerName: String = ""
    @State private var goToLobby = false
    
    init() {
        let repo = FirestoreRoomRepository()
        _viewModel = StateObject(wrappedValue: RoomViewModel(repository: repo))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Sandbag").font(.largeTitle.bold())
                
                TextField("Your name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                
                Button("Create Room") {
                    Task {
                        await viewModel.createRoom(playerName: playerName)
                        goToLobby = viewModel.room != nil
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                HStack {
                    TextField("6-char code", text: $joinCode)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 160)
                    
                    Button("Join Room") {
                        Task {
                            await viewModel.joinRoom(code: joinCode, playerName: playerName)
                            goToLobby = viewModel.room != nil
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || joinCode.count != 6)
                }
                
                if viewModel.isLoading { ProgressView() }
                
                if let err = viewModel.errorMessage {
                    Text(err).foregroundStyle(.red)
                }
                
                // Navigation to Lobby
                NavigationLink("", isActive: $goToLobby) {
                    if let localId = viewModel.localPlayerId {
                        RoomLobbyView(viewModel: viewModel, localPlayerId: localId)
                    } else {
                        Text("Error loading room…")
                    }
                }
                .hidden()
            }
            .padding()
        }
    }
}
