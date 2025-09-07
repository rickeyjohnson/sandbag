//
//  RoundSummaryView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/28/25.
//

import SwiftUI

struct RoundSummaryView: View {
    @ObservedObject var vm: GameViewModel
    let playerId: String
    let isHost: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
                .padding(.top, AppleDesign.spacing32)
                .padding(.bottom, AppleDesign.spacing24)
            
            ScrollView {
                LazyVStack(spacing: AppleDesign.spacing24) {
                    if let round = vm.game?.rounds.last {
                        roundResultsSection(round: round)
                    }
                    totalScoresSection
                }
                .padding(.horizontal, AppleDesign.spacing20)
                .padding(.bottom, AppleDesign.spacing32)
            }
            
            actionsSection
                .padding(.top, AppleDesign.spacing20)
                .padding(.horizontal, AppleDesign.spacing20)
                .padding(.bottom, AppleDesign.spacing32)
        }
        .background(AppleDesign.groupedBackground)
        .navigationTitle("Round Summary")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerSection: some View {
        VStack(spacing: AppleDesign.spacing12) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 40))
                .foregroundColor(AppleDesign.accent)
            
            Text("Round Complete")
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundColor(AppleDesign.label)
            
            Text("Here's how everyone performed this round")
                .font(.system(.body))
                .foregroundColor(AppleDesign.secondaryLabel)
                .multilineTextAlignment(.center)
        }
    }
    
    private func roundResultsSection(round: Round) -> some View {
        VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
            Text("Round Scores")
                .font(.system(.headline, weight: .semibold))
                .foregroundColor(AppleDesign.label)
            
            VStack(spacing: 0) {
                ForEach(Array(round.roundScore.keys.sorted().enumerated()), id: \.element) { index, teamId in
                    let score = round.roundScore[teamId] ?? 0
                    let teamColor: Color = teamId == "red" ? .red : .blue
                    let bid = round.teamBids[teamId]
                    
                    VStack(spacing: AppleDesign.spacing8) {
                        HStack {
                            Circle()
                                .fill(teamColor)
                                .frame(width: 16, height: 16)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(teamId.capitalized) Team")
                                    .font(.system(.body, weight: .semibold))
                                    .foregroundColor(AppleDesign.label)
                                
                                if let bid = bid {
                                    Text("Bid: \(bid)")
                                        .font(.system(.caption))
                                        .foregroundColor(AppleDesign.secondaryLabel)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(score >= 0 ? "+" : "")\(score)")
                                    .font(.system(.title3, weight: .bold))
                                    .foregroundColor(score >= 0 ? .green : .red)
                                
                                Text("points")
                                    .font(.system(.caption))
                                    .foregroundColor(AppleDesign.secondaryLabel)
                            }
                        }
                        
                        if index < round.roundScore.keys.count - 1 {
                            Divider()
                                .padding(.top, AppleDesign.spacing8)
                        }
                    }
                    .padding(.horizontal, AppleDesign.spacing16)
                    .padding(.vertical, AppleDesign.spacing12)
                }
            }
            .background(AppleDesign.background)
            .cornerRadius(AppleDesign.cornerRadius)
        }
    }
    
    private var totalScoresSection: some View {
        VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
            Text("Total Scores")
                .font(.system(.headline, weight: .semibold))
                .foregroundColor(AppleDesign.label)
            
            if let totals = vm.game?.teamTotals {
                VStack(spacing: 0) {
                    ForEach(Array(totals.keys.sorted().enumerated()), id: \.element) { index, teamId in
                        let total = totals[teamId] ?? 0
                        let teamColor: Color = teamId == "red" ? .red : .blue
                        
                        HStack {
                            Circle()
                                .fill(teamColor)
                                .frame(width: 12, height: 12)
                            
                            Text("\(teamId.capitalized) Team")
                                .font(.system(.body))
                                .foregroundColor(AppleDesign.label)
                            
                            Spacer()
                            
                            Text("\(total)")
                                .font(.system(.title3, weight: .bold))
                                .foregroundColor(teamColor)
                        }
                        .padding(.horizontal, AppleDesign.spacing16)
                        .padding(.vertical, AppleDesign.spacing12)
                        
                        if index < totals.keys.count - 1 {
                            Divider()
                                .padding(.leading, 28)
                        }
                    }
                }
                .background(AppleDesign.background)
                .cornerRadius(AppleDesign.cornerRadius)
                
                // Target score progress
                if let targetScore = vm.game?.targetScore {
                    let maxScore = totals.values.max() ?? 0
                    let progress = min(Double(maxScore) / Double(targetScore), 1.0)
                    
                    VStack(alignment: .leading, spacing: AppleDesign.spacing8) {
                        HStack {
                            Text("Progress to \(targetScore)")
                                .font(.system(.subheadline))
                                .foregroundColor(AppleDesign.secondaryLabel)
                            
                            Spacer()
                            
                            Text("\(Int(progress * 100))%")
                                .font(.system(.subheadline, weight: .semibold))
                                .foregroundColor(AppleDesign.accent)
                        }
                        
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(height: 6)
                    }
                    .padding(AppleDesign.spacing16)
                    .background(AppleDesign.background)
                    .cornerRadius(AppleDesign.cornerRadius)
                }
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: AppleDesign.spacing12) {
            if isHost {
                Button("Continue to Next Round") {
                    Task { await vm.startNextRound() }
                }
                .buttonStyle(ApplePrimaryButtonStyle())
                
                Text("As the host, you can start the next round when ready")
                    .font(.system(.caption))
                    .foregroundColor(AppleDesign.secondaryLabel)
                    .multilineTextAlignment(.center)
            } else {
                VStack(spacing: AppleDesign.spacing8) {
                    Image(systemName: "clock.fill")
                        .font(.system(.title2))
                        .foregroundColor(.orange)
                    
                    Text("Waiting for host...")
                        .font(.system(.headline, weight: .semibold))
                        .foregroundColor(AppleDesign.label)
                    
                    Text("The host will start the next round when ready")
                        .font(.system(.body))
                        .foregroundColor(AppleDesign.secondaryLabel)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, AppleDesign.spacing16)
            }
            
            Button("Quit Game") {
                Task { await vm.forfeitGame(playerId: playerId) }
            }
            .buttonStyle(ApplePrimaryButtonStyle(isDestructive: true))
        }
    }
}
