//
//  StandingsView.swift
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct StandingsView: View {
    let tournamentId: String
    @StateObject private var viewModel = StandingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showKnockoutSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.groupStandings.isEmpty {
                        emptyStateView
                    } else {
                        // Tournament header
                        if let tournament = viewModel.tournament {
                            tournamentHeaderView(tournament)
                        }
                        
                        // Knockout advancement button
                        knockoutAdvancementButton
                        
                        // Temporary debug info - TODO: Remove
                        if let tournament = viewModel.tournament {
                            debugInfoCard(tournament: tournament)
                        }
                        
                        // Group standings
                        ForEach(viewModel.groupStandings, id: \.groupName) { group in
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
            .navigationTitle("Standings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                // Temporary debug button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Debug") {
                        print("🐛 Debug button pressed")
                        print("🐛 canAdvanceToKnockout: \(viewModel.canAdvanceToKnockout)")
                        print("🐛 showKnockoutAdvancement: \(viewModel.showKnockoutAdvancement)")
                        print("🐛 isGroupStageComplete: \(viewModel.isGroupStageComplete)")
                        if let tournament = viewModel.tournament {
                            print("🐛 Tournament status: \(tournament.status)")
                            let groupMatches = tournament.matches.filter { $0.stage == .group }
                            let playedMatches = groupMatches.filter { $0.isPlayed }
                            print("🐛 Group matches: \(groupMatches.count), Played: \(playedMatches.count)")
                        }
                        
                        // Force show banner for testing
                        viewModel.showKnockoutAdvancement = true
                    }
                }
            }
            .refreshable {
                viewModel.refreshData(tournamentId: tournamentId)
            }
        }
        .onAppear {
            viewModel.startListening(tournamentId: tournamentId)
        }
        .onDisappear {
            viewModel.stopListening()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
        .alert("Advance to Knockout Stage", isPresented: $viewModel.showAdvancementAlert) {
            Button("Cancel", role: .cancel) {
                viewModel.showAdvancementAlert = false
            }
            
            Button("Advance") {
                Task {
                    await viewModel.advanceToKnockoutStage()
                }
            }
            .disabled(viewModel.isLoading)
        } message: {
            Text("This will create semi-finals and finals matches with the top 2 teams from each group. This action cannot be undone.")
        }
        .sheet(isPresented: $showKnockoutSheet) {
            KnockoutAdvancementSheet(viewModel: viewModel)
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
        .padding(.top, 100)
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
        .padding(.top, 100)
    }
    
    @ViewBuilder
    private func tournamentHeaderView(_ tournament: Tournament) -> some View {
        VStack(spacing: 12) {
            Text(tournament.name)
                .font(.title.bold())
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(tournament.courts)")
                        .font(.title2.bold())
                    Text("Courts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(tournament.numberOfGroups)")
                        .font(.title2.bold())
                    Text("Groups")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text(tournament.setType.rawValue.capitalized)
                        .font(.title2.bold())
                    Text("Sets")
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
            
            Text("W")
                .font(.caption.bold())
                .frame(width: 25)
            
            Text("L")
                .font(.caption.bold())
                .frame(width: 25)
            
            Text("GF")
                .font(.caption.bold())
                .frame(width: 30)
            
            Text("GA")
                .font(.caption.bold())
                .frame(width: 30)
            
            Text("GD")
                .font(.caption.bold())
                .frame(width: 35)
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
            
            // Games For
            Text("\(standing.pointsFor)")
                .font(.subheadline)
                .frame(width: 30)
            
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
    
    // TODO: Remove - Debug info for tournament progression
    @ViewBuilder
    private func debugInfoCard(tournament: Tournament) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🐛 DEBUG INFO")
                .font(.caption.bold())
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Tournament Status: \(tournament.status.rawValue)")
                Text("Total Teams: \(tournament.teams.count)")
                Text("Total Groups: \(tournament.groups.count)")
                Text("Total Matches: \(tournament.matches.count)")
                
                let groupMatches = tournament.matches.filter { $0.stage == .group }
                let playedMatches = groupMatches.filter { $0.isPlayed }
                
                Text("Group Matches: \(groupMatches.count)")
                Text("Played Group Matches: \(playedMatches.count)")
                    .foregroundColor(playedMatches.count == groupMatches.count ? .green : .red)
                
                Text("Can Advance: \(viewModel.canAdvanceToKnockout ? "YES" : "NO")")
                    .foregroundColor(viewModel.canAdvanceToKnockout ? .green : .red)
                    .font(.caption.bold())
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(.orange.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Knockout Advancement Button
    
    @ViewBuilder
    private var knockoutAdvancementButton: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "trophy.circle.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Knockout Stage")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                    if viewModel.isGroupStageComplete {
                        Text("Group stage complete - Ready to advance!")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    } else {
                        Text("Group stage in progress...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            Button(action: {
                showKnockoutSheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.right.circle.fill")
                    Text("View Knockout Details")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    StandingsView(tournamentId: "preview-tournament")
}
