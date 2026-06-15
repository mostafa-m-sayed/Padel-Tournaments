//
//  TournamentMatchesView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct TournamentMatchesView: View {
    let tournament: Tournament
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Quick matches overview
                VStack(alignment: .leading, spacing: 16) {
                    Text("Match Progress")
                        .font(.headline.bold())
                    
                    HStack {
                        StatCard(
                            title: "Completed",
                            value: "\(completedMatches)",
                            color: .green
                        )
                        
                        StatCard(
                            title: "In Progress",
                            value: "\(inProgressMatches)",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Pending",
                            value: "\(pendingMatches)",
                            color: .gray
                        )
                    }
                    
                    // Progress bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Tournament Progress")
                                .font(.caption.bold())
                            
                            Spacer()
                            
                            Text("\(Int(progress * 100))% Complete")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: progress)
                            .tint(.green)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(16)
                
                // Recent matches
                if !recentMatches.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Results")
                            .font(.headline.bold())
                        
                        VStack(spacing: 12) {
                            ForEach(recentMatches.prefix(3), id: \.id) { match in
                                RecentMatchRow(match: match, teams: tournament.teams)
                            }
                        }
                        
                        if recentMatches.count > 3 {
                            NavigationLink(destination: ScheduleView(tournamentId: tournament.id)) {
                                Text("View All Matches")
                            }
                            .font(.caption)
                            .foregroundColor(.accentColor)
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(16)
                }
                
                // Call to action
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                    
                    Text("View Complete Schedule")
                        .font(.headline.bold())
                    
                    Text("See all matches, courts, and manage scores")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink(destination: ScheduleView(tournamentId: tournament.id)) {
                        Text("Open Schedule")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                
                Spacer()
            }
            .padding()
            .padding(.bottom, 20) // Extra bottom padding for tab bar
        }
    }
    
    
    private var completedMatches: Int {
        tournament.matches.filter { $0.isPlayed }.count
    }
    
    private var inProgressMatches: Int {
        // For now, this could be matches that have been started but not completed
        // In a real app, you might track match state differently
        0
    }
    
    private var pendingMatches: Int {
        tournament.matches.filter { !$0.isPlayed }.count
    }
    
    private var progress: Double {
        guard !tournament.matches.isEmpty else { return 0 }
        return Double(completedMatches) / Double(tournament.matches.count)
    }
    
    private var recentMatches: [Match] {
        tournament.matches
            .filter { $0.isPlayed }
            .sorted { $0.round > $1.round } // Show most recent rounds first
    }
}

struct RecentMatchRow: View {
    let match: Match
    let teams: [Team]
    
    private var team1: Team? {
        teams.first { $0.id == match.team1Id }
    }
    
    private var team2: Team? {
        teams.first { $0.id == match.team2Id }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let group = match.groupId {
                    Text("Group \(group)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(4)
                } else {
                    Text(match.stage.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.purple.opacity(0.1))
                        .cornerRadius(4)
                }
                
                HStack {
                    Text(team1?.displayName ?? "Team 1")
                        .font(.subheadline)
                        .lineLimit(1)
                    
                    Text("vs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(team2?.displayName ?? "Team 2")
                        .font(.subheadline)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if let score1 = match.score1, let score2 = match.score2 {
                HStack(spacing: 8) {
                    Text("\(score1)")
                        .font(.title2.bold())
                        .foregroundColor(score1 > score2 ? .green : .primary)
                    
                    Text(":")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("\(score2)")
                        .font(.title2.bold())
                        .foregroundColor(score2 > score1 ? .green : .primary)
                }
            }
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    TournamentMatchesView(
        tournament: Tournament(
            id: "preview-tournament",
            name: "Test Tournament",
            courts: 2,
            numberOfGroups: 2,
            setType: .short,
            status: .groupStage,
            createdAt: Date(),
            courtAssignmentStrategy: .automatic
        )
    )
}
