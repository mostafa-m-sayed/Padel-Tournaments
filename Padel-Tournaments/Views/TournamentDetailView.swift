//
//  TournamentDetailView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct TournamentDetailView: View {
    let tournament: Tournament
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tournament Header
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(tournament.name)
                            .font(.title.bold())
                        
                        HStack {
                            StatusBadge(status: tournament.status)
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(tournament.courts) Courts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(tournament.setType.rawValue.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.gray.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                // Stats Row
                HStack {
                    StatCard(title: "Teams", value: "\(tournament.teams.count)", color: .accentColor)
                    StatCard(title: "Groups", value: "\(tournament.groups.count)", color: .accentColor)
                    StatCard(title: "Matches", value: "\(tournament.matches.count)", color: .accentColor)
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
                TournamentOverviewView(tournament: tournament)
                    .tag(0)
                
                TournamentStandingsView(tournament: tournament)
                    .tag(1)
                
                TournamentMatchesView(tournament: tournament)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TournamentDetailView(
            tournament: Tournament(
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
