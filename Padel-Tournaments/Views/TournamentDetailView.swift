//
//  TournamentDetailView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct TournamentDetailView: View {
    let initialTournament: Tournament
    let showBackButton: Bool
    @StateObject private var viewModel = TournamentDetailViewModel()
    @State private var selectedTab = 0
    @State private var showingExitAlert = false
    @Environment(\.dismiss) private var dismiss
    
    init(initialTournament: Tournament, showBackButton: Bool = true) {
        self.initialTournament = initialTournament
        self.showBackButton = showBackButton
    }
    
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
                
                // Tournament ID Section
                TournamentIdView(tournamentId: currentTournament.id)
                
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
                if currentTournament.status == .knockout || currentTournament.status == .completed {
                    Text("Knockout").tag(3)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Tab Content
            TabView(selection: $selectedTab) {
                TournamentOverviewView(tournament: currentTournament)
                    .tag(0)
                
                TournamentStandingsView(tournament: currentTournament, selectedTab: $selectedTab)
                    .tag(1)
                
                TournamentMatchesView(tournament: currentTournament)
                    .tag(2)
                
                if currentTournament.status == .knockout || currentTournament.status == .completed {
                    KnockoutStageView(tournament: currentTournament)
                        .tag(3)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(showBackButton) // Hide system back button when we show custom one
        .toolbar {
            if showBackButton {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        showingExitAlert = true
                    }
                }
            }
        }
        .alert("Leave Tournament", isPresented: $showingExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure you want to leave this tournament? You'll return to the main screen and will need to select or create a tournament again.")
        }
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
