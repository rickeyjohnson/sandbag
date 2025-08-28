//
//  PlayingView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/28/25.
//

import SwiftUI

struct PlayingView: View {
    @ObservedObject var vm: GameViewModel
    
    var body: some View {
        VStack {
            Text("Game in progress…")
                .font(.headline)
            
            Button("Finish Round") {
                // round moves to books entry after button
                // (handled in repo when all books are submitted)
            }
            .padding(.top, 12)
        }
        .padding()
    }
}
