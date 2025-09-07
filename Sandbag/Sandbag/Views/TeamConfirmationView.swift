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
        VStack(spacing: 0) {
            // Header
            headerSection
                .padding(.top, AppleDesign.spacing32)
                .padding(.bottom, AppleDesign.spacing24)
            
            ScrollView {
                LazyVStack(spacing: AppleDesign.spacing24) {
                    confirmationSection
                    if let teamBids = vm.game?.currentRound?.teamBids, !teamBids.isEmpty {
                        teamBidsSection(teamBids: teamBids)
                    }
                }
                .padding(.horizontal, AppleDesign.spacing20)
                .padding(.bottom, AppleDesign.spacing32)
            }
        }
        .background(AppleDesign.groupedBackground)
        .navigationTitle("Team Bid")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerSection: some View {
        VStack(spacing: AppleDesign.spacing12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 40))
                .foregroundColor(AppleDesign.accent)
            
            Text("Confirm Team Bid")
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundColor(AppleDesign.label)
            
            Text("Work with your teammate to set your final bid")
                .font(.system(.body))
                .foregroundColor(AppleDesign.secondaryLabel)
                .multilineTextAlignment(.center)
        }
    }
    
    private var confirmationSection: some View {
        VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
            if let round = vm.game?.currentRound,
               let team = vm.game?.players.first(where: { $0.id == playerId })?.team {
                
                if round.teamConfirmers[team.rawValue] == playerId {
                    // Current player is the confirmer
                    VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
                        Text("You're confirming the \(team.rawValue.capitalized) team bid")
                            .font(.system(.headline, weight: .semibold))
                            .foregroundColor(team == .red ? .red : .blue)
                        
                        VStack(alignment: .leading, spacing: AppleDesign.spacing8) {
                            Text("Team Bid (0-13)")
                                .font(.system(.subheadline))
                                .foregroundColor(AppleDesign.secondaryLabel)
                            
                            HStack(spacing: AppleDesign.spacing12) {
                                TextField("0", text: $teamBid)
                                    .font(.system(.title, weight: .bold))
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .padding(AppleDesign.spacing16)
                                    .background(AppleDesign.background)
                                    .cornerRadius(AppleDesign.cornerRadius)
                                    .frame(width: 80)
                                
                                Button("Confirm Bid") {
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
                                .buttonStyle(ApplePrimaryButtonStyle())
                                .disabled(Int(teamBid) == nil || Int(teamBid)! < 0 || Int(teamBid)! > 13)
                            }
                        }
                    }
                } else {
                    // Not the confirmer - waiting state
                    VStack(spacing: AppleDesign.spacing16) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.orange)
                        
                        Text("Waiting for teammate...")
                            .font(.system(.headline, weight: .semibold))
                            .foregroundColor(AppleDesign.label)
                        
                        Text("Your teammate is confirming the \(team.rawValue.capitalized) team bid")
                            .font(.system(.body))
                            .foregroundColor(AppleDesign.secondaryLabel)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppleDesign.spacing32)
                }
            }
        }
    }
    
    private func teamBidsSection(teamBids: [String: Int]) -> some View {
        VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
            Text("Team Bids")
                .font(.system(.headline, weight: .semibold))
                .foregroundColor(AppleDesign.label)
            
            VStack(spacing: 0) {
                ForEach(Array(teamBids.keys.sorted().enumerated()), id: \.element) { index, teamId in
                    let bid = teamBids[teamId] ?? 0
                    let teamColor: Color = teamId == "red" ? .red : .blue
                    
                    HStack {
                        Circle()
                            .fill(teamColor)
                            .frame(width: 12, height: 12)
                        
                        Text("\(teamId.capitalized) Team")
                            .font(.system(.body))
                            .foregroundColor(AppleDesign.label)
                        
                        Spacer()
                        
                        Text("\(bid)")
                            .font(.system(.body, weight: .semibold))
                            .foregroundColor(teamColor)
                    }
                    .padding(.horizontal, AppleDesign.spacing16)
                    .padding(.vertical, AppleDesign.spacing12)
                    
                    if index < teamBids.keys.count - 1 {
                        Divider()
                            .padding(.leading, 28)
                    }
                }
            }
            .background(AppleDesign.background)
            .cornerRadius(AppleDesign.cornerRadius)
        }
    }
}
