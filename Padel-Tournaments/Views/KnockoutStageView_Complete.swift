//
//  KnockoutStageView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct KnockoutStageView: View {
    let tournament: Tournament
    @StateObject private var viewModel: KnockoutStageViewModel
    @State private var selectedMatch: Match?
    @State private var showingScoreEntry = false
    @Environment(\.dismiss) private var dismiss
    
    init(tournament: Tournament) {
        self.tournament = tournament
        self._viewModel = StateObject(wrappedValue: KnockoutStageViewModel(tournamentId: tournament.id))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with tournament info
                headerView
                
                // Tournament progress indicator
                progressView
                
                // Knockout matches sections
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error)
                } else {
                    knockoutMatchesView
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showingScoreEntry) {
            if let match = selectedMatch {
                ScoreEntryView(
                    match: match,
                    teams: tournament.teams,
                    tournament: viewModel.tournament ?? tournament
                ) { score1, score2 in
                    Task {
                        await viewModel.updateMatchScore(
                            matchId: match.id,
                            score1: score1,
                            score2: score2
                        )
                    }
                }
            }
        }
        .onAppear {
            viewModel.tournament = tournament // Set initial tournament data
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .shadow(color: .orange, radius: 4, x: 0, y: 2)
            
            Text(tournament.name)
                .font(.title.bold())
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(knockoutCourtsInUse)")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                    Text("Courts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(knockoutTeams.count)")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    Text("Teams")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(knockoutMatches.count)")
                        .font(.title2.bold())
                        .foregroundColor(.purple)
                    Text("Matches")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var progressView: some View {
        VStack(spacing: 12) {
            Text("Tournament Progress")
                .font(.headline.bold())
            
            HStack(spacing: 16) {
                ProgressStageView(
                    title: "Group Stage",
                    isCompleted: true,
                    isCurrent: false,
                    color: .green
                )
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                
                ProgressStageView(
                    title: "Semifinals",
                    isCompleted: allSemifinalsComplete,
                    isCurrent: !allSemifinalsComplete,
                    color: .purple
                )
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                
                ProgressStageView(
                    title: "Finals",
                    isCompleted: finalMatch?.isPlayed ?? false,
                    isCurrent: allSemifinalsComplete && !(finalMatch?.isPlayed ?? false),
                    color: .gold
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading knockout matches...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.top, 100)
    }
    
    @ViewBuilder
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error Loading Matches")
                .font(.title2.bold())
                .foregroundColor(.red)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await viewModel.loadTournament()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.red.opacity(0.1))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var knockoutMatchesView: some View {
        VStack(spacing: 24) {
            if !semifinalMatches.isEmpty {
                knockoutSectionView(
                    title: "Semifinals",
                    matches: semifinalMatches,
                    color: .purple,
                    icon: "medal"
                )
            }
            
            if let thirdPlaceMatch = thirdPlaceMatch {
                knockoutSectionView(
                    title: "Third Place Playoff",
                    matches: [thirdPlaceMatch],
                    color: .orange,
                    icon: "medal.fill"
                )
            }
            
            if let finalMatch = finalMatch {
                knockoutSectionView(
                    title: "Final",
                    matches: [finalMatch],
                    color: .gold,
                    icon: "crown.fill"
                )
            }
        }
    }
    
    @ViewBuilder
    private func knockoutSectionView(title: String, matches: [Match], color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(matches.count) match\(matches.count == 1 ? "" : "es")")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .foregroundColor(color)
                    .cornerRadius(6)
            }
            
            VStack(spacing: 12) {
                ForEach(matches, id: \.id) { match in
                    KnockoutMatchCard(
                        match: match,
                        teams: tournament.teams,
                        color: color
                    ) {
                        selectedMatch = match
                        showingScoreEntry = true
                    }
                }
            }
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Computed Properties
    
    private var knockoutMatches: [Match] {
        (viewModel.tournament ?? tournament).matches.filter { $0.stage != .group }
    }
    
    private var knockoutTeams: Set<String> {
        // Get unique teams that are actually qualified for knockout
        // This should be top 2 teams from each group (4 total for 2 groups)
        let qualifiedTeamIds = knockoutMatches
            .filter { $0.stage == .semi } // Only look at semifinal matches to get qualified teams
            .flatMap { [$0.team1Id, $0.team2Id] }
        return Set(qualifiedTeamIds)
    }
    
    private var semifinalMatches: [Match] {
        knockoutMatches.filter { $0.stage == .semi }
    }
    
    private var thirdPlaceMatch: Match? {
        knockoutMatches.first { $0.stage == .thirdPlace }
    }
    
    private var finalMatch: Match? {
        knockoutMatches.first { $0.stage == .final }
    }
    
    private var allSemifinalsComplete: Bool {
        let semis = semifinalMatches
        return !semis.isEmpty && semis.allSatisfy { $0.isPlayed }
    }
    
    private var knockoutCourtsInUse: Int {
        // Calculate courts actually needed for knockout matches
        let activeSemis = semifinalMatches.filter { !$0.isPlayed }
        let activeThirdPlace = thirdPlaceMatch != nil && !(thirdPlaceMatch?.isPlayed ?? true) ? 1 : 0
        let activeFinal = finalMatch != nil && !(finalMatch?.isPlayed ?? true) ? 1 : 0
        
        // Return max courts needed at any time: semifinals need 2 courts, finals need 1
        if !activeSemis.isEmpty {
            return min(activeSemis.count, 2) // Max 2 courts for semifinals
        } else if activeThirdPlace > 0 || activeFinal > 0 {
            return activeThirdPlace + activeFinal // 1-2 courts for final matches
        } else {
            return min(knockoutMatches.count, 2) // Default to reasonable number
        }
    }
}

// MARK: - Supporting Views

struct ProgressStageView: View {
    let title: String
    let isCompleted: Bool
    let isCurrent: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(isCompleted ? color : (isCurrent ? color.opacity(0.3) : Color.gray.opacity(0.2)))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: isCompleted ? "checkmark" : (isCurrent ? "play.fill" : "circle"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isCompleted ? .white : (isCurrent ? color : .gray))
                )
            
            Text(title)
                .font(.caption.bold())
                .foregroundColor(isCompleted ? color : (isCurrent ? color : .gray))
        }
    }
}

struct KnockoutMatchCard: View {
    let match: Match
    let teams: [Team]
    let color: Color
    let onTap: () -> Void
    
    private var team1: Team? {
        teams.first { $0.id == match.team1Id }
    }
    
    private var team2: Team? {
        teams.first { $0.id == match.team2Id }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Court \(match.court)")
                        .font(.caption.bold())
                        .foregroundColor(color)
                    
                    Text("Round \(match.round)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 60)
                .padding(.vertical, 8)
                .background(color.opacity(0.15))
                .cornerRadius(8)
                
                VStack(spacing: 8) {
                    teamMatchRow(
                        team: team1,
                        teamName: team1?.displayName ?? "TBD",
                        score: match.score1,
                        isWinner: match.isPlayed && (match.score1 ?? 0) > (match.score2 ?? 0)
                    )
                    
                    Divider()
                    
                    teamMatchRow(
                        team: team2,
                        teamName: team2?.displayName ?? "TBD",
                        score: match.score2,
                        isWinner: match.isPlayed && (match.score2 ?? 0) > (match.score1 ?? 0)
                    )
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    if match.isPlayed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        
                        Text("Complete")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "play.circle")
                            .font(.title2)
                            .foregroundColor(color)
                        
                        Text("Tap to Score")
                            .font(.caption2)
                            .foregroundColor(color)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(match.isPlayed ? .green.opacity(0.3) : color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func teamMatchRow(team: Team?, teamName: String, score: Int?, isWinner: Bool) -> some View {
        HStack {
            Text(teamName)
                .font(.subheadline)
                .fontWeight(isWinner ? .bold : .regular)
                .foregroundColor(isWinner ? .primary : .secondary)
                .lineLimit(1)
            
            Spacer()
            
            if let score = score {
                Text("\(score)")
                    .font(.title3.bold())
                    .foregroundColor(isWinner ? .green : .primary)
                    .frame(minWidth: 30)
            } else {
                Text("-")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(minWidth: 30)
            }
            
            if isWinner {
                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
    }
}

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}

#Preview {
    KnockoutStageView(
        tournament: Tournament(
            id: "preview-tournament",
            name: "Summer Championship",
            courts: 3,
            numberOfGroups: 4,
            setType: .short,
            status: .knockout,
            createdAt: Date(),
            courtAssignmentStrategy: .automatic
        )
    )
}