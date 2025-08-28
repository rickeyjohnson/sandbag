//
//  TeamConfirmationView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/28/25.
//

import SwiftUI

struct TeamConfirmationView: View {
    @ObservedObject var vm: GameViewModel
    let playerId: String
    @State private var teamBid = ""
    
    var body: some View {
        VStack {
            Text("Confirm your team's bid")
                .font(.headline)
            
            TextField("Team Bid", text: $teamBid)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .frame(width: 100)
            
            Button("Confirm Bid") {
                if let bidValue = Int(teamBid),
                   let team = vm.game?.players.first(where: { $0.id == playerId })?.team {
                    Task { await vm.confirmTeamBid(teamId: team.rawValue, bid: bidValue, comfirmedBy: playerId) }
                }
            }
            .padding(.top, 12)
            
            if let teamBids = vm.game?.currentRound?.teamBids {
                List {
                    ForEach(teamBids.keys.sorted(), id: \.self) { id in
                        Text("\(id): \(teamBids[id] ?? 0)")
                    }
                }
            }
        }
        .padding()
    }
}
