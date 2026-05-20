//
//  TournamentStandingsView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct TournamentStandingsView: View {
    let tournament: Tournament
    @StateObject private var standingsViewModel = StandingsViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if standingsViewModel.isLoading {
                    loadingView
                } else if standingsViewModel.groupStandings.isEmpty {
                    emptyStateView
                } else {
                    // Group standings
                    ForEach(standingsViewModel.groupStandings, id: \.groupName) { group in
                        groupStandingsView(
                            groupName: group.groupName,
                            standings: group.standings
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .onAppear {
            standingsViewModel.startListening(tournamentId: tournament.id)
        }
        .onDisappear {
            standingsViewModel.stopListening()
        }
        .alert("Error", isPresented: .constant(standingsViewModel.error != nil)) {
            Button("OK") {
                standingsViewModel.error = nil
            }
        } message: {
            Text(standingsViewModel.error?.localizedDescription ?? "")
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading standings...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Standings Yet")
                .font(.title2.bold())
            
            Text("Standings will appear as matches are completed")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    @ViewBuilder
    private func groupStandingsView(groupName: String, standings: [StandingEntry]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Group header
            HStack {
                VStack(alignment: .leading) {
                    Text("Group \(groupName)")
                        .font(.title2.bold())
                        .foregroundColor(groupColor(for: groupName))
                    
                    Text("\(standings.count) teams")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Qualification indicator
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Top 2 Advance")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    
                    Text("to Knockout")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Standings table
            VStack(spacing: 0) {
                // Header row
                standingsHeaderRow
                
                // Team rows
                ForEach(Array(standings.enumerated()), id: \.element.id) { index, standing in
                    standingsTeamRow(standing: standing, position: index + 1)
                        .background(rowBackground(for: index, total: standings.count))
                }
            }
            .background(.regularMaterial)
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private var standingsHeaderRow: some View {
        HStack {
            Text("Pos")
                .font(.caption.bold())
                .frame(width: 35)
            
            Text("Team")
                .font(.caption.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("PTS")
                .font(.caption.bold())
                .frame(width: 35)
                .help("Points (Games Won)")
            
            Text("W")
                .font(.caption.bold())
                .frame(width: 25)
                .help("Matches Won")
            
            Text("L")
                .font(.caption.bold())
                .frame(width: 25)
                .help("Matches Lost")
            
            Text("GA")
                .font(.caption.bold())
                .frame(width: 30)
                .help("Games Against")
            
            Text("GD")
                .font(.caption.bold())
                .frame(width: 35)
                .help("Goal Difference")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.quaternary)
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    private func standingsTeamRow(standing: StandingEntry, position: Int) -> some View {
        HStack {
            // Position with qualification indicator
            HStack(spacing: 4) {
                Text("\(position)")
                    .font(.headline.bold())
                    .foregroundColor(position <= 2 ? .green : .primary)
                
                if position <= 2 {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .frame(width: 35)
            
            // Team name
            VStack(alignment: .leading, spacing: 2) {
                Text(standing.team.displayName)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                if standing.matchesPlayed == 0 {
                    Text("No matches played")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Points (Games Won) - Primary ranking factor
            Text("\(standing.pointsFor)")
                .font(.subheadline.bold())
                .foregroundColor(.blue)
                .frame(width: 35)
            
            // Wins
            Text("\(standing.wins)")
                .font(.subheadline.bold())
                .foregroundColor(.green)
                .frame(width: 25)
            
            // Losses
            Text("\(standing.losses)")
                .font(.subheadline.bold())
                .foregroundColor(.red)
                .frame(width: 25)
            
            // Games Against
            Text("\(standing.pointsAgainst)")
                .font(.subheadline)
                .frame(width: 30)
            
            // Goal Difference
            Text("\(standing.pointsFor - standing.pointsAgainst)")
                .font(.subheadline.bold())
                .foregroundColor(standing.pointsFor - standing.pointsAgainst > 0 ? .green : 
                               standing.pointsFor - standing.pointsAgainst < 0 ? .red : .primary)
                .frame(width: 35)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
    
    private func groupColor(for groupName: String) -> Color {
        switch groupName {
        case "A": return .blue
        case "B": return .green
        case "C": return .orange
        case "D": return .purple
        case "E": return .pink
        case "F": return .cyan
        case "G": return .indigo
        case "H": return .mint
        default: return .gray
        }
    }
    
    private func rowBackground(for index: Int, total: Int) -> Color {
        if index < 2 {
            // Top 2 qualify - subtle green background
            return .green.opacity(0.05)
        } else {
            return .clear
        }
    }
}

#Preview {
    TournamentStandingsView(
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