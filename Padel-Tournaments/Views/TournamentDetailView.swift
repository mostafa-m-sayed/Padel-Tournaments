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
                    StatCard(title: "Teams", value: "\(tournament.teams.count)")
                    StatCard(title: "Groups", value: "\(tournament.groups.count)")
                    StatCard(title: "Matches", value: "\(tournament.matches.count)")
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

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// Placeholder views for the tabs
struct TournamentOverviewView: View {
    let tournament: Tournament
    
    var body: some View {
        VStack {
            Text("Tournament Overview")
            Text("Coming soon...")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TournamentStandingsView: View {
    let tournament: Tournament
    
    var body: some View {
        VStack {
            Text("Tournament Standings")
            Text("Coming soon...")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TournamentMatchesView: View {
    let tournament: Tournament
    
    var body: some View {
        VStack {
            Text("Tournament Matches")
            Text("Coming soon...")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        TournamentDetailView(
            tournament: Tournament(
                id: "1",
                name: "Summer Championship",
                courts: 3,
                setType: .short,
                status: .groupStage,
                createdAt: Date()
            )
        )
    }
}
