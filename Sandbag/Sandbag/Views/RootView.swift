//
//  RootView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/31/25.
//

import SwiftUI

//struct RootView: View {
//    @State private var path = NavigationPath()
//    
//    var body: some View {
//        NavigationStack(path: $path) {
//            HomeView(path: $path)
//                .navigationDestination(for: String.self) { id in
//                    // Determine if id is a room or game
//                    if id.starts(with: "room_") {
//                        RoomLobbyView(roomID: id, path: $path)
//                    } else if id.starts(with: "game_") {
//                        GameView(gameID: id, path: $path)
//                    } else {
//                        Text("Unknown ID")
//                    }
//                }
//        }
//    }
//}
//
//
//#Preview {
//    RootView()
//}
