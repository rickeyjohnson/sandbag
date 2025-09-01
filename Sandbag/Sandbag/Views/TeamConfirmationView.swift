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
            
            if let round = vm.game?.currentRound,
               let team = vm.game?.players.first(where: { $0.id == playerId })?.team {
                
                if round.teamConfirmers[team.rawValue] == playerId {
                    // Current player is the confirmer
                    TextField("Team Bid", text: $teamBid)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .frame(width: 100)
                    
                    Button("Confirm \(team.rawValue.capitalized) Bid") {
                        if let bidValue = Int(teamBid) {
                            Task {
                                await vm.confirmTeamBid(
                                    teamId: team.rawValue,
                                    bid: bidValue,
                                    comfirmedBy: playerId
                                )
                            }
                        }
                    }
                    .padding(.top, 12)
                    .disabled(Int(teamBid) == nil || Int(teamBid)! < 0 || Int(teamBid)! > 13)
                    
                } else {
                    // Not the confirmer
                    Text("Waiting for your teammate to confirm the \(team.rawValue.capitalized) bid…")
                        .foregroundColor(.secondary)
                        .padding(.top, 12)
                }
            }
            
            if let teamBids = vm.game?.currentRound?.teamBids {
                List {
                    ForEach(teamBids.keys.sorted(), id: \.self) { id in
                        Text("\(id.capitalized): \(teamBids[id] ?? 0)")
                    }
                }
            }
        }
        .padding()
    }
}
