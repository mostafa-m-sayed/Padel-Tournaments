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
                
                // Tournament completion celebration (if tournament is complete)
                if finalMatch?.isPlayed == true && !viewModel.topThreeTeams.isEmpty {
                    tournamentCompleteCelebration
                }
                
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
        .sheet(item: $selectedMatch) { match in
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
        .onAppear {
            viewModel.tournament = tournament // Set initial tournament data
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
        .sheet(isPresented: $viewModel.showTournamentResults) {
            if let tournament = viewModel.tournament {
                TournamentResultsShareView(
                    tournament: tournament,
                    topTeams: viewModel.topThreeTeams,
                    finalScore: viewModel.finalMatchScore
                )
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var tournamentCompleteCelebration: some View {
        VStack(spacing: 16) {
            // Celebration header
            VStack(spacing: 8) {
                Text("🎉 TOURNAMENT COMPLETE! 🎉")
                    .font(.title2.bold())
                    .foregroundColor(.green)
                    .tracking(1)
                
                if let winner = viewModel.tournamentWinner {
                    HStack(spacing: 8) {
                        Text("🏆")
                            .font(.title)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CHAMPIONS")
                                .font(.caption.bold())
                                .foregroundColor(.yellow)
                                .tracking(1)
                            
                            Text("\(winner.player1.name) & \(winner.player2.name)")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                        }
                        
                        Text("🏆")
                            .font(.title)
                    }
                }
            }
            
            // Share results button
            Button(action: {
                viewModel.showTournamentResults = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                    
                    Text("Share Tournament Results")
                        .font(.headline.bold())
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.green, .blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding()
        .background(.green.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.green.opacity(0.3), lineWidth: 2)
        )
    }
    
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
        if semifinalMatches.isEmpty && finalMatch == nil && thirdPlaceMatch == nil {
            EmptyView()
        } else {
            KnockoutBracketView(
                semifinals: semifinalMatches,
                finalMatch: finalMatch,
                thirdPlaceMatch: thirdPlaceMatch,
                teams: tournament.teams
            ) { match in
                selectedMatch = match
            }
        }
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