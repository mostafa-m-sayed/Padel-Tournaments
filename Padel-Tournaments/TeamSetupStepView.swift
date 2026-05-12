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
            VStack {
                PrimaryButton(title: "Add Team") {
                    showAddTeamSheet = true
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
            player1Name = "TestF"
            player2Name = "TestL"
        }
    }
}

#Preview {
    TeamSetupStepView(viewModel: CreateTournamentViewModel())
}
