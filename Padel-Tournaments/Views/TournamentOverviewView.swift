//
//  TournamentOverviewView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct TournamentOverviewView: View {
    let tournament: Tournament
    @State private var repository = TournamentRepository()
    @State private var isFillingScores = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Tournament Stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tournament Information")
                        .font(.headline.bold())
                    
                    VStack(spacing: 12) {
                        InfoRow(label: "Tournament Name", value: tournament.name)
                        InfoRow(label: "Status", value: tournament.status.displayName)
                        InfoRow(label: "Courts", value: "\(tournament.courts)")
                        InfoRow(label: "Groups", value: "\(tournament.numberOfGroups)")
                        InfoRow(label: "Set Type", value: tournament.setType.rawValue.capitalized)
                        InfoRow(label: "Strategy", value: tournament.courtAssignmentStrategy.displayName)
                        InfoRow(label: "Created", value: DateFormatter.shortDate.string(from: tournament.createdAt))
                    }
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(16)
                
                // Quick Stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Stats")
                        .font(.headline.bold())
                    
                    HStack {
                        StatCard(title: "Matches", value: "\(tournament.matches.count)", color: .blue)
                        StatCard(title: "Completed", value: "\(completedMatches)", color: .green)
                        StatCard(title: "Remaining", value: "\(tournament.matches.count - completedMatches)", color: .orange)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(16)
                
                // Navigation Actions
                VStack(spacing: 12) {
                    NavigationLink(destination: TournamentStandingsView(tournament: tournament)) {
                        HStack {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("View Standings")
                                    .font(.headline.bold())
                                    .foregroundColor(.white)
                                
                                Text("Check team positions and group rankings")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(.blue.gradient)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    // Test button for development
                    Button(action: fillRandomScores) {
                        HStack {
                            if isFillingScores {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "dice")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(isFillingScores ? "Filling Scores..." : "Fill Random Scores")
                                    .font(.headline.bold())
                                    .foregroundColor(.white)
                                
                                Text("Testing: Complete all matches with random results")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "flask")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(.orange.gradient)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .disabled(isFillingScores)
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(16)
                
                // Teams List
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Teams")
                            .font(.headline.bold())
                        
                        Spacer()
                        
                        Text("\(tournament.teams.count) teams")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.gray.opacity(0.1))
                            .cornerRadius(6)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(tournament.teams) { team in
                            TeamCard(team: team)
                        }
                    }
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(16)
            }
            .padding()
        }
        .alert("Fill Random Scores", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var completedMatches: Int {
        tournament.matches.filter { $0.isPlayed }.count
    }
    
    private func fillRandomScores() {
        guard !isFillingScores else { return }
        
        isFillingScores = true
        
        Task {
            do {
                let unplayedMatches = tournament.matches.filter { !$0.isPlayed }
                
                if unplayedMatches.isEmpty {
                    await MainActor.run {
                        alertMessage = "All matches have already been played!"
                        showingAlert = true
                        isFillingScores = false
                    }
                    return
                }
                
                // Fill random scores for all unplayed matches
                for match in unplayedMatches {
                    let score1 = Int.random(in: 0...6)
                    let score2 = Int.random(in: 0...6)
                    
                    // Ensure there's always a winner (no ties in padel)
                    let finalScore1: Int
                    let finalScore2: Int
                    
                    if score1 == score2 {
                        // Add a random winner
                        if Bool.random() {
                            finalScore1 = score1 + 1
                            finalScore2 = score2
                        } else {
                            finalScore1 = score1
                            finalScore2 = score2 + 1
                        }
                    } else {
                        finalScore1 = score1
                        finalScore2 = score2
                    }
                    
                    // Update match score in the database
                    try await repository.updateMatchScore(
                        tournamentId: tournament.id,
                        matchId: match.id,
                        score1: finalScore1,
                        score2: finalScore2
                    )
                }
                
                await MainActor.run {
                    alertMessage = "Successfully filled random scores for \(unplayedMatches.count) matches! Navigate to the Matches or Standings tab to see the updates."
                    showingAlert = true
                    isFillingScores = false
                }
                
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to update scores: \(error.localizedDescription)"
                    showingAlert = true
                    isFillingScores = false
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.bold())
        }
    }
}

struct TeamCard: View {
    let team: Team
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(team.displayName)
                .font(.subheadline.bold())
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            HStack {
                Image(systemName: "person.2")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(team.player1.name)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(team.player2.name)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    TournamentOverviewView(
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
