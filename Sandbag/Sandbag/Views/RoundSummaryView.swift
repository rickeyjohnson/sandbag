//
//  RoundSummaryView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/28/25.
//

import SwiftUI

struct RoundSummaryView: View {
    @ObservedObject var vm: GameViewModel
    var body: some View {
        VStack {
            Text("Round Summary")
                .font(.title2)
                .padding(.bottom, 8)
            
            if let round = vm.game?.rounds.last {
                ForEach(round.roundScore.keys.sorted(), id: \.self) { teamId in
                    Text("\(teamId): \(round.roundScore[teamId] ?? 0)")
                }
            }
            
            Divider().padding()
            
            Text("Total Scores")
                .font(.headline)
            if let totals = vm.game?.teamTotals {
                ForEach(totals.keys.sorted(), id: \.self) { teamId in
                    Text("\(teamId): \(totals[teamId] ?? 0)")
                }
            }
            
            Button("Continue to Next Round") {
                // trigger new Round creation (TODO in repo/vm)
            }
            .padding(.top, 20)
        }
        .padding()
    }
}
