//
//  KnockoutAdvancementSheet.swift
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct KnockoutAdvancementSheet: View {
    @ObservedObject var viewModel: StandingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showKnockoutStage = false
    @State private var advancementSuccessful = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Status indicator or success message
                    if advancementSuccessful {
                        successMessageView
                    } else {
                        statusIndicatorView
                    }
                    
                    // Qualified teams section
                    if viewModel.isGroupStageComplete {
                        qualifiedTeamsView
                    } else {
                        incompleteGroupStageView
                    }
                    
                    // Action button
                    actionButtonView
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationTitle("Knockout Stage")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Advance to Knockout Stage", isPresented: $viewModel.showAdvancementAlert) {
            Button("Cancel", role: .cancel) {
                viewModel.showAdvancementAlert = false
            }
            
            Button("Advance") {
                Task {
                    await viewModel.advanceToKnockoutStage()
                    advancementSuccessful = true
                }
            }
            .disabled(viewModel.isLoading)
        } message: {
            Text("This will create semi-finals and finals matches with the top 2 teams from each group. This action cannot be undone.")
        }
        .sheet(isPresented: $showKnockoutStage) {
            if let tournament = viewModel.tournament {
                KnockoutStageView(tournament: tournament)
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Advance the top 2 teams from each group to the semi-finals")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private var statusIndicatorView: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.isGroupStageComplete ? "checkmark.circle.fill" : "clock.circle.fill")
                .font(.title2)
                .foregroundColor(viewModel.isGroupStageComplete ? .green : .orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.isGroupStageComplete ? "Group Stage Complete" : "Group Stage In Progress")
                    .font(.headline)
                    .foregroundColor(viewModel.isGroupStageComplete ? .green : .orange)
                
                if let tournament = viewModel.tournament {
                    let groupMatches = tournament.matches.filter { $0.stage == .group }
                    let playedMatches = groupMatches.filter { $0.isPlayed }
                    
                    Text("\(playedMatches.count) of \(groupMatches.count) group matches completed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var successMessageView: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Knockout Stage Created!")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Text("Semifinals and finals matches have been generated. You can now manage knockout matches.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var qualifiedTeamsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Qualified Teams")
                .font(.title2.bold())
            
            ForEach(viewModel.groupStandings, id: \.groupName) { group in
                groupQualifiedTeamsView(group: group)
            }
        }
    }
    
    @ViewBuilder
    private func groupQualifiedTeamsView(group: StandingsViewModel.GroupStanding) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Group \(group.groupName)")
                .font(.headline)
                .foregroundColor(groupColor(for: group.groupName))
            
            let topTwo = Array(group.standings.prefix(2))
            
            VStack(spacing: 8) {
                ForEach(Array(topTwo.enumerated()), id: \.element.id) { index, standing in
                    HStack(spacing: 12) {
                        // Position badge
                        Text("\(index + 1)")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(index == 0 ? .yellow : .gray))
                        
                        // Team info
                        VStack(alignment: .leading, spacing: 2) {
                            Text(standing.team.displayName)
                                .font(.subheadline.bold())
                            
                            Text("W: \(standing.wins) • L: \(standing.losses) • PTS: \(standing.pointsFor)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(.green.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var incompleteGroupStageView: some View {
        VStack(spacing: 16) {
            Image(systemName: "hourglass")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Group Stage Not Complete")
                .font(.title2.bold())
                .foregroundColor(.orange)
            
            Text("All group stage matches must be completed before advancing to the knockout stage.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let tournament = viewModel.tournament {
                let groupMatches = tournament.matches.filter { $0.stage == .group }
                let playedMatches = groupMatches.filter { $0.isPlayed }
                let remainingMatches = groupMatches.count - playedMatches.count
                
                Text("\(remainingMatches) matches remaining")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var actionButtonView: some View {
        VStack(spacing: 12) {
            if advancementSuccessful {
                // Show knockout stage navigation after successful advancement
                Button(action: {
                    showKnockoutStage = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                        Text("View Knockout Matches")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                
                Button("Close") {
                    dismiss()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            } else {
                // Original advancement button
                Button(action: {
                    if viewModel.isGroupStageComplete {
                        viewModel.showAdvancementAlert = true
                    } else {
                        // Show some feedback that it's not ready
                        print("Group stage not complete yet!")
                    }
                }) {
                    HStack(spacing: 12) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: viewModel.isGroupStageComplete ? "arrow.right.circle.fill" : "clock.circle.fill")
                        }
                        
                        Text(viewModel.isGroupStageComplete ? "Advance to Knockout" : "Waiting for Group Stage")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: viewModel.isGroupStageComplete ? [.green, .blue] : [.gray, .gray]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .disabled(!viewModel.isGroupStageComplete || viewModel.isLoading)
            }
        }
    }
    
    // MARK: - Helper Methods
    
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
}

#Preview {
    // Create a mock view model for preview
    let mockViewModel = StandingsViewModel()
    return KnockoutAdvancementSheet(viewModel: mockViewModel)
}
