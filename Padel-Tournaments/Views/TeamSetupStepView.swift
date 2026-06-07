//
//  TeamSetupStepView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct TeamSetupStepView: View {
    @ObservedObject var viewModel: CreateTournamentViewModel
    @State private var player1Name = ""
    @State private var player2Name = ""
    @State private var showAddTeamSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add Teams")
                            .font(.title2.bold())
                        
                        Text("Minimum 4 teams, must be even number")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(viewModel.teams.count) teams")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundColor(Color.accentColor)
                        .cornerRadius(6)
                }
                
                if !viewModel.teams.isEmpty && viewModel.teams.count < 4 {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.orange)
                        
                        Text("Add at least \(4 - viewModel.teams.count) more team\(4 - viewModel.teams.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Spacer()
                    }
                } else if viewModel.teams.count % 2 != 0 {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.orange)
                        
                        Text("Add one more team to make it even")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // Teams List
            if viewModel.teams.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(Array(viewModel.teams.enumerated()), id: \.element.id) { index, team in
                        TeamRowView(team: team) {
                            viewModel.removeTeam(at: index)
                        }
                    }
                }
                .listStyle(.plain)
            }
            
            // Add Team Button
            VStack(spacing: 12) {
                PrimaryButton(title: "Add Team") {
                    showAddTeamSheet = true
                }
                .padding(.horizontal)
                
                // TODO: DELETE - Testing button for development only
                Button(action: {
                    createTestingTeams()
                }) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver")
                        Text("Add 10 Test Teams")
                    }
                    .font(.caption.bold())
                    .foregroundColor(.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.orange.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.orange.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showAddTeamSheet) {
            AddTeamSheet(
                player1Name: $player1Name,
                player2Name: $player2Name
            ) {
                viewModel.addTeam(player1Name: player1Name, player2Name: player2Name)
                player1Name = ""
                player2Name = ""
                showAddTeamSheet = false
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.2.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Teams Added Yet")
                    .font(.title3.bold())
                
                Text("Add your first team to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
    
    // TODO: DELETE - Testing function for development only
    private func createTestingTeams() {
        let teamNames = [
            ("Alice", "Brown"),      // Team A1
            ("Bob", "Clark"),        // Team B2
            ("Charlie", "Davis"),    // Team C3
            ("Diana", "Evans"),      // Team D4
            ("Eve", "Foster"),       // Team E5
            ("Frank", "Green"),      // Team F6
            ("Grace", "Hill"),       // Team G7
            ("Henry", "Jones"),      // Team H8
            ("Ivy", "King"),         // Team I9
            ("Jack", "Lee")          // Team J10
        ]
        
        for (index, (firstName, lastName)) in teamNames.enumerated() {
            let teamNumber = index + 1
            let teamName = "Team \(firstName.first!)\(teamNumber)"
            
            // Create players with first letter of first name + team number pattern
            let player1Name = "\(firstName) \(teamNumber)"
            let player2Name = "\(lastName) \(teamNumber)"
            
            print("🧪 Creating test team: \(teamName) - \(player1Name) & \(player2Name)")
            
            viewModel.addTeam(
                player1Name: player1Name,
                player2Name: player2Name
            )
        }
        
        print("🧪 Created \(teamNames.count) test teams successfully!")
    }
}

struct TeamRowView: View {
    let team: Team
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(team.displayName)
                    .font(.headline)
                
                HStack {
                    Text(team.player1.name)
                    Text("•")
                    Text(team.player2.name)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AddTeamSheet: View {
    @Binding var player1Name: String
    @Binding var player2Name: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    TextField("Player 1 Name", text: $player1Name)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Player 2 Name", text: $player2Name)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Add Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onAdd()
                    }
                    .disabled(player1Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                             player2Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear() {
            player1Name = "TestF - \(Int.random(in: 1...1000))"
            player2Name = "TestL - \(Int.random(in: 1...1000))"
        }
    }
}

#Preview {
    TeamSetupStepView(viewModel: CreateTournamentViewModel())
}
