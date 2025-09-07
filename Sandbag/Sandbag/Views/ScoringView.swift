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
        VStack(spacing: 0) {
            // Header
            headerSection
                .padding(.top, AppleDesign.spacing32)
                .padding(.bottom, AppleDesign.spacing24)
            
            ScrollView {
                LazyVStack(spacing: AppleDesign.spacing24) {
                    scoringSection
                    progressSection
                }
                .padding(.horizontal, AppleDesign.spacing20)
                .padding(.bottom, AppleDesign.spacing32)
            }
        }
        .background(AppleDesign.groupedBackground)
        .navigationTitle("Scoring")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerSection: some View {
        VStack(spacing: AppleDesign.spacing12) {
            Image(systemName: "book.fill")
                .font(.system(size: 40))
                .foregroundColor(AppleDesign.accent)
            
            Text("Record Your Score")
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundColor(AppleDesign.label)
            
            Text("How many books did you win this round?")
                .font(.system(.body))
                .foregroundColor(AppleDesign.secondaryLabel)
                .multilineTextAlignment(.center)
        }
    }
    
    private var scoringSection: some View {
        let alreadySubmitted = vm.game?.currentRound?.booksWon[playerId] != nil
        
        return VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
            if alreadySubmitted {
                VStack(spacing: AppleDesign.spacing16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text("Score Submitted!")
                        .font(.system(.headline, weight: .semibold))
                        .foregroundColor(.green)
                    
                    Text("Waiting for other players...")
                        .font(.system(.body))
                        .foregroundColor(AppleDesign.secondaryLabel)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppleDesign.spacing24)
            } else {
                VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
                    Text("Books Won (0-13)")
                        .font(.system(.headline, weight: .semibold))
                        .foregroundColor(AppleDesign.label)
                    
                    HStack(spacing: AppleDesign.spacing12) {
                        TextField("0", text: $books)
                            .font(.system(.title, weight: .bold))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .padding(AppleDesign.spacing16)
                            .background(AppleDesign.background)
                            .cornerRadius(AppleDesign.cornerRadius)
                            .frame(width: 80)
                        
                        Button("Submit Books") {
                            if let booksValue = Int(books) {
                                Task { await vm.submitBooks(playerId: playerId, books: booksValue) }
                            }
                        }
                        .buttonStyle(ApplePrimaryButtonStyle())
                        .disabled(Int(books) == nil || Int(books)! < 0 || Int(books)! > 13)
                    }
                }
            }
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: AppleDesign.spacing16) {
            Text("Submission Progress")
                .font(.system(.headline, weight: .semibold))
                .foregroundColor(AppleDesign.label)
            
            if let round = vm.game?.currentRound,
               let totalPlayers = vm.game?.players.count {
                let submittedCount = round.booksWon.count
                let progress = Double(submittedCount) / Double(totalPlayers)
                
                VStack(spacing: AppleDesign.spacing12) {
                    HStack {
                        Text("\(submittedCount) of \(totalPlayers) players")
                            .font(.system(.body))
                            .foregroundColor(AppleDesign.label)
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.system(.body, weight: .semibold))
                            .foregroundColor(AppleDesign.accent)
                    }
                    
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(height: 8)
                    
                    if submittedCount < totalPlayers {
                        Text("Waiting for remaining players...")
                            .font(.system(.caption))
                            .foregroundColor(AppleDesign.secondaryLabel)
                    } else {
                        HStack(spacing: AppleDesign.spacing8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(.caption))
                                .foregroundColor(.green)
                            
                            Text("All players have submitted!")
                                .font(.system(.caption, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(AppleDesign.spacing16)
                .background(AppleDesign.background)
                .cornerRadius(AppleDesign.cornerRadius)
            }
        }
    }
}
