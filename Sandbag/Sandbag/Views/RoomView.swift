////
////  RoomView.swift
////  Sandbag
////
////  Created by Rickey Johnson on 8/25/25.
////
//
//import SwiftUI
//
//struct RoomView: View {
//    @StateObject var vm = RoomViewModel(repository: MockRoomRespository())
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("Spades Room").font(.title.bold())
//
//            TextField("Your name", text: $vm.nameInput)
//                .textFieldStyle(.roundedBorder)
//                .textInputAutocapitalization(.words)
//
//            HStack {
//                Button("Create Room") { vm.createRoom() }
//                    .buttonStyle(.borderedProminent)
//
//                TextField("6-char code", text: $vm.codeInput)
//                    .textFieldStyle(.roundedBorder)
//                    .frame(width: 120)
//
//                Button("Join") { vm.joinRoom() }
//                    .buttonStyle(.bordered)
//            }
//            
//            if vm.isLoading { ProgressView() }
//            
//            if let room = vm.room {
//                Divider().padding(.vertical, 8)
//                Text("Room Code: \(room.code)").font(.headline)
//                List(vm.players) { p in
//                    HStack {
//                        Text(p.name)
//                        Spacer()
//                        if p.id == vm.localPlayerId { Text("You").foregroundStyle(.secondary) }
//                    }
//                }
//                Button("Leave Room", role: .destructive) { vm.leaveRoom() }
//            }
//            
//            if let err = vm.errorMessage {
//                Text(err).foregroundColor(.red)
//            }
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    RoomView()
//}
