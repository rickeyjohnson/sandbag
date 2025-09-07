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
        VStack(spacing: 0) {
            // Header
            headerSection
                .padding(.top, AppleDesign.spacing32)
                .padding(.bottom, AppleDesign.spacing24)
            
            ScrollView {
                LazyVStack(spacing: AppleDesign.spacing24) {
                    biddingSection
                    if let game = vm.game, let bids = game.currentRound?.bids, !bids.isEmpty {
                        currentBidsSection(game: game, bids: bids)
                    }
                }
                .padding(.horizontal, AppleDesign.spacing20)
                .padding(.bottom, AppleDesign.spacing32)
            }
        }
        .background(AppleDesign.groupedBackground)
        .navigationTitle("Bidding")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerSection: some View {
        VStack(spacing: AppleDesign.spacing12) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 40))
                .foregroundColor(AppleDesign.accent)
            
            Text("Place Your Bid")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(AppleDesign.label)
        }
    }
    
    private var biddingSection: some View {
        VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
            Text("Your Bid (0-13)")
                .font(.system(.headline, weight: .semibold))
                .foregroundColor(AppleDesign.label)
            
            HStack(spacing: AppleDesign.spacing12) {
                TextField("0", text: $bid)
                    .font(.system(.title, weight: .bold))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .padding(AppleDesign.spacing16)
                    .background(AppleDesign.background)
                    .cornerRadius(AppleDesign.cornerRadius)
                    .frame(width: 80)
                
                Button("Submit") {
                    if let bidValue = Int(bid) {
                        Task { await vm.submitBid(playerId: playerId, bid: bidValue) }
                    }
                }
                .buttonStyle(ApplePrimaryButtonStyle())
                .disabled(Int(bid) == nil || Int(bid)! < 0 || Int(bid)! > 13)
            }
        }
    }
    
    private func currentBidsSection(game: Game, bids: [String: Int]) -> some View {
        VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
            Text("Current Bids")
                .font(.system(.headline, weight: .semibold))
                .foregroundColor(AppleDesign.label)
            
            VStack(spacing: 0) {
                ForEach(Array(bids.keys.sorted().enumerated()), id: \.element) { index, playerId in
                    let name = game.playerName(for: playerId)
                    let bidValue = bids[playerId] ?? 0
                    
                    HStack {
                        Text(name)
                            .font(.system(.body))
                            .foregroundColor(AppleDesign.label)
                        
                        Spacer()
                        
                        Text("\(bidValue)")
                            .font(.system(.body, weight: .semibold))
                            .foregroundColor(AppleDesign.accent)
                    }
                    .padding(.horizontal, AppleDesign.spacing16)
                    .padding(.vertical, AppleDesign.spacing12)
                    
                    if index < bids.keys.count - 1 {
                        Divider()
                            .padding(.leading, AppleDesign.spacing16)
                    }
                }
            }
            .background(AppleDesign.background)
            .cornerRadius(AppleDesign.cornerRadius)
        }
    }
}
