//
//  JoinTournamentView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct JoinTournamentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tournamentCode = ""
    @State private var player1Name = ""
    @State private var player2Name = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tournament") {
                    TextField("Tournament Code", text: $tournamentCode)
                        .textContentType(.oneTimeCode)
                }
                
                Section("Your Team") {
                    TextField("Player 1 Name", text: $player1Name)
                        .textContentType(.name)
                    
                    TextField("Player 2 Name", text: $player2Name)
                        .textContentType(.name)
                }
            }
            .navigationTitle("Join Tournament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Join") {
                        joinTournament()
                    }
                    .disabled(tournamentCode.isEmpty || player1Name.isEmpty || player2Name.isEmpty)
                }
            }
        }
    }
    
    private func joinTournament() {
        // TODO: Implement tournament joining
        dismiss()
    }
}

#Preview {
    JoinTournamentView()
}