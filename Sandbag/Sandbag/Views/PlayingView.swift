//
//  PlayingView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/28/25.
//

import SwiftUI

struct PlayingView: View {
    @ObservedObject var vm: GameViewModel
    let playerId: String
    let isHost: Bool
    
    var body: some View {
        VStack(spacing: AppleDesign.spacing32) {
            Spacer()
            
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 60))
                .foregroundColor(AppleDesign.accent)
            
            VStack(spacing: AppleDesign.spacing12) {
                Text("Game in Progress")
                    .font(.system(.largeTitle, weight: .bold))
                    .foregroundColor(AppleDesign.label)
                
                Text("Play your cards strategically!")
                    .font(.system(.body))
                    .foregroundColor(AppleDesign.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            if isHost {
                Button("Finish Round") {
                    Task { await vm.finishRound() }
                }
                .buttonStyle(ApplePrimaryButtonStyle())
            } else {
                VStack(spacing: AppleDesign.spacing8) {
                    Image(systemName: "clock.fill")
                        .font(.system(.title2))
                        .foregroundColor(.orange)
                    
                    Text("Waiting for host to finish the round...")
                        .font(.system(.body))
                        .foregroundColor(AppleDesign.secondaryLabel)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle("Playing")
        .navigationBarTitleDisplayMode(.large)
    }
}
