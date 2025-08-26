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
    @State private var goToLobby = false
    
    init() {
        let repo = MockRoomRespository()
        _viewModel = StateObject(wrappedValue: RoomViewModel(repository: repo))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Sandbag").font(.largeTitle.bold())
                
                TextField("Your name", text: $viewModel.nameInput)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
                
                Button("Create Room") {
                    Task {
                        await viewModel.createRoom()
                        goToLobby = viewModel.room != nil
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                HStack {
                    TextField("6-char code", text: $viewModel.codeInput)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 160)
                    
                    Button("Join Room") {
                        Task {
                            await viewModel.joinRoom()
                            goToLobby = viewModel.room != nil
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.codeInput.count != 6)
                }
                
                if viewModel.isLoading { ProgressView() }
                
                if let err = viewModel.errorMessage { Text(err).foregroundStyle(.red) }
                
                NavigationLink("", isActive: $goToLobby) {
                    RoomLobbyView(viewModel: viewModel)
                }
                .hidden()
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
