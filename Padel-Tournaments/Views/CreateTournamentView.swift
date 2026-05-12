//
//  CreateTournamentView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct CreateTournamentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tournamentName = ""
    @State private var numberOfCourts = 1
    @State private var setType: SetType = .short
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tournament Details") {
                    TextField("Tournament Name", text: $tournamentName)
                    
                    Stepper("Courts: \(numberOfCourts)", value: $numberOfCourts, in: 1...10)
                    
                    Picker("Set Type", selection: $setType) {
                        Text("Short (First to 4)").tag(SetType.short)
                        Text("Long (First to 6)").tag(SetType.long)
                    }
                }
            }
            .navigationTitle("Create Tournament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createTournament()
                    }
                    .disabled(tournamentName.isEmpty)
                }
            }
        }
    }
    
    private func createTournament() {
        // TODO: Implement tournament creation
        dismiss()
    }
}

#Preview {
    CreateTournamentView()
}