//
//  ScoringView.swift
//  Sandbag
//
//  Created by Rickey Johnson on 8/28/25.
//

import SwiftUI

struct ScoringView: View {
    @ObservedObject var vm: GameViewModel
    let playerId: String
    @State private var books = ""
    
    var body: some View {
        let alreadySubmitted = vm.game?.currentRound?.booksWon[playerId] != nil

        VStack {
            Text("Enter books won")
                .font(.headline)
            
            TextField("Books", text: $books)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .frame(width: 100)
            
            Button(alreadySubmitted ? "Waiting for others..." : "Submit Books") {
                if let booksValue = Int(books) {
                    Task { await vm.submitBooks(playerId: playerId, books: booksValue) }
                }
            }
            .padding(.top, 12)
            .buttonStyle(.borderedProminent)
            .disabled(alreadySubmitted)
            
            if let round = vm.game?.currentRound {
                Text("\(round.booksWon.count)/\(vm.game?.players.count ?? 0) players submitted")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
