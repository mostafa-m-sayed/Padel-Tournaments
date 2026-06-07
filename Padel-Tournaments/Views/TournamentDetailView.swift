//
//  TournamentDetailView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct TournamentDetailView: View {
    let initialTournament: Tournament
    @StateObject private var viewModel = TournamentDetailViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tournament Header
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(currentTournament.name)
                            .font(.title.bold())
                        
                        HStack {
                            StatusBadge(status: currentTournament.status)
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(currentTournament.courts) Courts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(currentTournament.setType.rawValue.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.gray.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                // Stats Row
                HStack {
                    StatCard(title: "Teams", value: "\(currentTournament.teams.count)", color: .accentColor)
                    StatCard(title: "Groups", value: "\(currentTournament.groups.count)", color: .accentColor)
                    StatCard(title: "Matches", value: "\(currentTournament.matches.count)", color: .accentColor)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // Tab Picker
            Picker("Section", selection: $selectedTab) {
                Text("Overview").tag(0)
                Text("Standings").tag(1)
                Text("Matches").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Tab Content
            TabView(selection: $selectedTab) {
                TournamentOverviewView(tournament: currentTournament)
                    .tag(0)
                
                TournamentStandingsView(tournament: currentTournament)
                    .tag(1)
                
                TournamentMatchesView(tournament: currentTournament)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startListening(tournamentId: initialTournament.id)
            viewModel.tournament = initialTournament // Set initial data
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
    
    private var currentTournament: Tournament {
        viewModel.tournament ?? initialTournament
    }
}

#Preview {
    NavigationStack {
        TournamentDetailView(
            initialTournament: Tournament(
                id: "1",
                name: "Summer Championship",
                courts: 3,
                numberOfGroups: 4,
                setType: .short,
                status: .groupStage,
                createdAt: Date(),
                courtAssignmentStrategy: .automatic
            )
        )
    }
}
