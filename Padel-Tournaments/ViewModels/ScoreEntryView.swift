//
//  ScoreEntryView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct ScoreEntryView: View {
    let match: Match
    let teams: [Team]
    let tournament: Tournament
    let onScoreUpdated: (Int, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var team1Score: Int
    @State private var team2Score: Int
    @State private var isSubmitting = false
    
    private var team1: Team? {
        teams.first { $0.id == match.team1Id }
    }
    
    private var team2: Team? {
        teams.first { $0.id == match.team2Id }
    }
    
    init(match: Match, teams: [Team], tournament: Tournament, onScoreUpdated: @escaping (Int, Int) -> Void) {
        self.match = match
        self.teams = teams
        self.tournament = tournament
        self.onScoreUpdated = onScoreUpdated
        
        // Initialize with existing scores or 0
        self._team1Score = State(initialValue: match.score1 ?? 0)
        self._team2Score = State(initialValue: match.score2 ?? 0)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Match header
                    matchHeaderView
                    
                    // Score entry section
                    scoreEntryView
                    
                    // Action buttons
                    actionButtonsView
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Score Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var matchHeaderView: some View {
        VStack(spacing: 16) {
            // Match details
            HStack {
                VStack {
                    Text("Round \(match.round)")
                        .font(.caption.bold())
                    Text("Court \(match.court)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(.quaternary)
                .cornerRadius(8)
                
                Spacer()
                
                VStack {
                    Text("Group \(match.groupId ?? "—")")
                        .font(.caption.bold())
                        .foregroundColor(groupColor)
                    
                    if match.isPlayed {
                        Text("Completed")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Text("In Progress")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            // Teams
            VStack(spacing: 12) {
                teamInfoView(team: team1, title: "Team 1")
                
                Text("VS")
                    .font(.title2.bold())
                    .foregroundColor(.secondary)
                
                teamInfoView(team: team2, title: "Team 2")
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func teamInfoView(team: Team?, title: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let team = team {
                    Text(team.displayName)
                        .font(.headline.bold())
                    
                    HStack {
                        Text(team.player1.name)
                        Text("&")
                            .foregroundColor(.secondary)
                        Text(team.player2.name)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                } else {
                    Text("Unknown Team")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var scoreEntryView: some View {
        VStack(spacing: 24) {
            Text("Enter Match Score")
                .font(.title2.bold())
            
            HStack(spacing: 30) {
                // Team 1 score
                VStack(spacing: 12) {
                    Text(String(team1?.displayName.prefix(15) ?? "Team 1") + (team1?.displayName.count ?? 0 > 15 ? "..." : ""))
                        .font(.subheadline.bold())
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    scoreControlView(
                        score: $team1Score,
                        color: team1Score > team2Score ? .green : .primary
                    )
                }
                .frame(maxWidth: .infinity)
                
                Text(":")
                    .font(.largeTitle.bold())
                    .foregroundColor(.secondary)
                
                // Team 2 score
                VStack(spacing: 12) {
                    Text(String(team2?.displayName.prefix(15) ?? "Team 2") + (team2?.displayName.count ?? 0 > 15 ? "..." : ""))
                        .font(.subheadline.bold())
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    scoreControlView(
                        score: $team2Score,
                        color: team2Score > team1Score ? .green : .primary
                    )
                }
                .frame(maxWidth: .infinity)
            }
            
            // Quick score buttons for common padel scores
            quickScoreButtonsView
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func scoreControlView(score: Binding<Int>, color: Color) -> some View {
        VStack(spacing: 8) {
            Text("\(score.wrappedValue)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .frame(width: 80, height: 80)
                .background(color.opacity(0.1))
                .cornerRadius(16)
            
            HStack(spacing: 12) {
                Button {
                    if score.wrappedValue > 0 {
                        score.wrappedValue -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .disabled(score.wrappedValue <= 0)
                
                Button {
                    score.wrappedValue += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    @ViewBuilder
    private var quickScoreButtonsView: some View {
        VStack(spacing: 8) {
            Text("Quick Scores (\(tournament.setType.rawValue.capitalized) Set)")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(quickScoreOptions, id: \.self) { scoreText in
                    quickScoreButton(scoreText)
                }
            }
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func quickScoreButton(_ scoreText: String) -> some View {
        Button {
            let components = scoreText.split(separator: "-")
            if components.count == 2,
               let score1 = Int(components[0]),
               let score2 = Int(components[1]) {
                team1Score = score1
                team2Score = score2
            }
        } label: {
            Text(scoreText)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.quaternary)
                .foregroundColor(.primary)
                .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            Button {
                submitScore()
            } label: {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    
                    Text(match.isPlayed ? "Update Score" : "Submit Score")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isSubmitting || (team1Score == 0 && team2Score == 0))
            
            if match.isPlayed {
                Button {
                    clearScore()
                } label: {
                    HStack {
                        Image(systemName: "trash.circle")
                        Text("Clear Score")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private var groupColor: Color {
        switch match.groupId {
        case "A": return .blue
        case "B": return .green
        case "C": return .orange
        case "D": return .purple
        default: return .gray
        }
    }
    
    private var quickScoreOptions: [String] {
        let target = tournament.setType.target
        
        // Generate common padel scores based on set type
        var scores: [String] = []
        
        // Clean sweeps and common scores
        scores.append("\(target)-0")
        scores.append("0-\(target)")
        scores.append("\(target)-1")
        scores.append("\(target)-2")
        scores.append("2-\(target)")
        scores.append("\(target)-3")
        scores.append("3-\(target)")
        
        if target == 6 {
            // Long sets (first to 6)
            scores.append("6-4")
//            scores.append("7-5") // Deuce scenario - must win by 2 when tied at 6-6
        } else {
            // Short sets (first to 4) 
            // In padel, short sets still follow deuce rules
            scores.append("4-2")
//            scores.append("5-3") // Deuce scenario - must win by 2 when tied at 4-4
        }
        
        return scores
    }
    
    private func submitScore() {
        guard team1Score > 0 || team2Score > 0 else { return }
        
        isSubmitting = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onScoreUpdated(team1Score, team2Score)
            isSubmitting = false
            dismiss()
        }
    }
    
    private func clearScore() {
        team1Score = 0
        team2Score = 0
        
        onScoreUpdated(0, 0)
        dismiss()
    }
}

#Preview {
    ScoreEntryView(
        match: Match(
            id: "preview-match",
            court: 1,
            round: 1,
            stage: .group,
            team1Id: "team1",
            team2Id: "team2",
            score1: nil,
            score2: nil,
            groupId: "A"
        ),
        teams: [
            Team(
                id: "team1",
                name: "Team Alpha",
                player1: Player(id: "p1", name: "John"),
                player2: Player(id: "p2", name: "Jane")
            ),
            Team(
                id: "team2",
                name: "Team Beta",
                player1: Player(id: "p3", name: "Bob"),
                player2: Player(id: "p4", name: "Alice")
            )
        ],
        tournament: Tournament(
            id: "preview-tournament",
            name: "Test Tournament",
            courts: 2,
            numberOfGroups: 4,
            setType: .short, // Try changing this to .short to see different quick scores
            status: .groupStage,
            createdAt: Date(),
            courtAssignmentStrategy: .automatic
        )
    ) { score1, score2 in
        print("Score updated: \(score1) - \(score2)")
    }
}
