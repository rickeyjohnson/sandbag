//
//  BiddingView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/27/25.
//

import SwiftUI
import Combine

struct BiddingView: View {
    @ObservedObject var vm: GameViewModel
    let playerId: String
    @State private var bid = ""
    
    var body: some View {
        VStack {
            Text("Enter your bid")
                .font(.headline)
            
            TextField("Bid", text: $bid)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .frame(width: 100)
            
            Button("Submit Bid") {
                if let bidValue = Int(bid) {
                    Task { await vm.submitBid(playerId: playerId, bid: bidValue) }
                }
            }
            .padding(.top, 12)
            .disabled(Int(bid) == nil || Int(bid)! < 0 || Int(bid)! > 13)
            
            if let game = vm.game, let bids = game.currentRound?.bids {
                List {
                    ForEach(bids.keys.sorted(), id: \.self) { id in
                        let name = game.playerName(for: id)
                        Text("\(name): \(bids[id] ?? 0)")
                    }
                }
            }
        }
        .padding()
    }
}
