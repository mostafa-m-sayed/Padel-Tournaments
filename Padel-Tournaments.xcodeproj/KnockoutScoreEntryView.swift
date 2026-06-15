//
//  KnockoutScoreEntryView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct KnockoutScoreEntryView: View {
    let match: Match
    let tournament: Tournament
    let onScoreUpdate: (Int, Int) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var team1Score = ""
    @State private var team2Score = ""
    @State private var isSubmitting = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private var team1: Team? {
        tournament.teams.first { $0.id == match.team1Id }
    }
    
    private var team2: Team? {
        tournament.teams.first { $0.id == match.team2Id }
    }
    
    private var isValidScore: Bool {
        guard let score1 = Int(team1Score),
              let score2 = Int(team2Score),
              score1 >= 0,
              score2 >= 0 else { return false }
        
        // In padel, there should be a clear winner (no ties)
        return score1 != score2
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Match Header
                matchHeaderView
                
                // Score Entry Section
                scoreEntrySection
                
                // Submission Button
                submitButtonSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("Enter Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Score Entry Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                setupExistingScores()
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var matchHeaderView: some View {
        VStack(spacing: 16) {
            // Stage Badge
            HStack {
                Spacer()
                
                VStack(spacing: 4) {
                    Text(match.stage.displayName.uppercased())
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(stageColor.gradient)
                        .cornerRadius(20)
                    
                    Text("Court \(match.court)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Tournament Info
            VStack(spacing: 4) {
                Text(tournament.name)
                    .font(.title2.bold())
                
                Text("Round \(match.round)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var scoreEntrySection: some View {
        VStack(spacing: 20) {
            Text("Enter Match Result")
                .font(.title3.bold())
            
            VStack(spacing: 16) {
                // Team 1 Score Entry
                teamScoreEntry(
                    team: team1,
                    scoreBinding: $team1Score,
                    label: "Team 1"
                )
                
                // VS Divider
                HStack {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(stageColor.opacity(0.3))
                    
                    Text("VS")
                        .font(.headline.bold())
                        .foregroundColor(stageColor)
                        .padding(.horizontal, 16)
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(stageColor.opacity(0.3))
                }
                
                // Team 2 Score Entry
                teamScoreEntry(
                    team: team2,
                    scoreBinding: $team2Score,
                    label: "Team 2"
                )
            }
            
            // Scoring Instructions
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    
                    Text("Scoring Instructions")
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Enter the final score for each team")
                    Text("• Scores must be different (no ties in padel)")
                    Text("• Example: 6-4, 6-3, 7-5")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(.blue.opacity(0.05))
            .cornerRadius(12)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func teamScoreEntry(team: Team?, scoreBinding: Binding<String>, label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(team?.displayName ?? label)
                        .font(.headline.bold())
                    
                    if let team = team {
                        HStack(spacing: 8) {
                            Text(team.player1.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(team.player2.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Score Input
                TextField("Score", text: scoreBinding)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 80)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    @ViewBuilder
    private var submitButtonSection: some View {
        VStack(spacing: 12) {
            Button(action: submitScore) {
                HStack(spacing: 12) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                    }
                    
                    Text(isSubmitting ? "Submitting..." : "Submit Score")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: isValidScore ? [stageColor, stageColor.opacity(0.8)] : [.gray, .gray]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: stageColor.opacity(0.3), radius: isValidScore ? 4 : 0, x: 0, y: 2)
            }
            .disabled(!isValidScore || isSubmitting)
            
            if !team1Score.isEmpty && !team2Score.isEmpty && !isValidScore {
                Text("Scores must be different (no ties allowed)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Helper Properties & Methods
    
    private var stageColor: Color {
        switch match.stage {
        case .semi: return .orange
        case .thirdPlace: return .brown
        case .final: return .gold
        default: return .purple
        }
    }
    
    private func setupExistingScores() {
        if let score1 = match.score1 {
            team1Score = String(score1)
        }
        if let score2 = match.score2 {
            team2Score = String(score2)
        }
    }
    
    private func submitScore() {
        guard isValidScore,
              let score1 = Int(team1Score),
              let score2 = Int(team2Score) else {
            showError("Invalid score entered. Please check your input.")
            return
        }
        
        isSubmitting = true
        
        // Add a small delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onScoreUpdate(score1, score2)
            isSubmitting = false
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

#Preview {
    KnockoutScoreEntryView(
        match: Match(
            id: "preview-match",
            court: 1,
            round: 1,
            stage: .semi,
            team1Id: "team1",
            team2Id: "team2",
            score1: nil,
            score2: nil,
            groupId: nil
        ),
        tournament: Tournament(
            id: "preview-tournament",
            name: "Test Championship",
            courts: 2,
            numberOfGroups: 2,
            setType: .short,
            status: .knockout,
            createdAt: Date(),
            courtAssignmentStrategy: .automatic
        )
    ) { _, _ in
        // Preview action
    }
}