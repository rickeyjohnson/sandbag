//
//  HomeView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/25/25.
//

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
            VStack(spacing: 0) {
                // Header
                headerSection
                    .padding(.top, AppleDesign.spacing32)
                    .padding(.bottom, AppleDesign.spacing24)
                
                // Content
                ScrollView {
                    LazyVStack(spacing: AppleDesign.spacing24) {
                        nameSection
                        createRoomSection
                        joinRoomSection
                        if viewModel.isLoading || viewModel.errorMessage != nil {
                            statusSection
                        }
                    }
                    .padding(.horizontal, AppleDesign.spacing20)
                    .padding(.bottom, AppleDesign.spacing32)
                }
            }
            .background(AppleDesign.groupedBackground)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $goToLobby) {
                if let localId = viewModel.localPlayerId {
                    RoomLobbyView(viewModel: viewModel, localPlayerId: localId)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppleDesign.spacing12) {
            Image(systemName: "suit.spade.fill")
                .font(.system(size: 50, weight: .medium))
                .foregroundColor(AppleDesign.accent)
            
            Text("Sandbag")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(AppleDesign.label)
        }
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: AppleDesign.spacing12) {
            Text("Player Name")
                .font(.system(.headline, weight: .semibold))
                .foregroundColor(AppleDesign.label)
            
            TextField("Enter your name", text: $playerName)
                .font(.system(.body))
                .textInputAutocapitalization(.words)
                .padding(AppleDesign.spacing16)
                .background(AppleDesign.background)
                .cornerRadius(AppleDesign.cornerRadius)
        }
    }
    
    private var createRoomSection: some View {
        Button("Create New Room") {
            Task {
                await viewModel.createRoom(playerName: playerName)
                if viewModel.room != nil {
                    goToLobby = true
                }
            }
        }
        .buttonStyle(ApplePrimaryButtonStyle())
        .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    private var joinRoomSection: some View {
        VStack(alignment: .leading, spacing: AppleDesign.spacing12) {
            Text("Join Room")
                .font(.system(.headline, weight: .semibold))
                .foregroundColor(AppleDesign.label)
            
            HStack(spacing: AppleDesign.spacing12) {
                TextField("Room Code", text: $joinCode)
                    .font(.system(.body, weight: .medium))
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(AppleDesign.spacing16)
                    .background(AppleDesign.background)
                    .cornerRadius(AppleDesign.cornerRadius)
                    .frame(maxWidth: 120)
                
                Button("Join") {
                    Task {
                        await viewModel.joinRoom(code: joinCode, playerName: playerName)
                        if viewModel.room != nil {
                            goToLobby = true
                        }
                    }
                }
                .buttonStyle(AppleSecondaryButtonStyle())
                .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || joinCode.count != 6)
            }
        }
    }
    
    private var statusSection: some View {
        Group {
            if viewModel.isLoading {
                HStack(spacing: AppleDesign.spacing12) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Connecting...")
                        .font(.system(.body))
                        .foregroundColor(AppleDesign.secondaryLabel)
                }
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(.body))
                    .foregroundColor(.red)
                    .padding(AppleDesign.spacing16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(AppleDesign.cornerRadius)
            }
        }
    }
}
