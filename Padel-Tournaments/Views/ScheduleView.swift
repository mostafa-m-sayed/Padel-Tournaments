//
//  ScheduleView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct ScheduleView: View {
    let tournamentId: String
    @StateObject private var viewModel: ScheduleViewModel
    @State private var isReorderingEnabled = false
    @State private var selectedMatch: Match?
    
    init(tournamentId: String) {
        self.tournamentId = tournamentId
        self._viewModel = StateObject(wrappedValue: ScheduleViewModel(tournamentId: tournamentId))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with tournament info and controls
                headerView
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading tournament...")
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    ErrorView(error: error) {
                        Task { await viewModel.loadTournament() }
                    }
                    Spacer()
                } else {
                    // Matches list
                    matchesListView
                }
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(CourtAssignmentStrategy.allCases, id: \.self) { strategy in
                            Button(strategy.displayName) {
                                Task {
                                    await viewModel.updateCourtStrategy(strategy)
                                }
                            }
                        }
                        
                        Divider()
                        
                        Button("Reassign All Courts") {
                            Task {
                                await viewModel.reassignAllCourts()
                            }
                        }
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            viewModel.showTableView = true
                        } label: {
                            Image(systemName: "tablecells")
                        }
                        
                        Button {
                            withAnimation(.easeInOut) {
                                isReorderingEnabled.toggle()
                            }
                        } label: {
                            if isReorderingEnabled {
                                Text("Done")
                            } else {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadTournament()
        }
        .sheet(isPresented: $viewModel.showTableView) {
            ScheduleTableView(tournamentId: tournamentId)
        }
        .sheet(item: $selectedMatch) { match in
            if let tournament = viewModel.tournament {
                ScoreEntryView(
                    match: match,
                    teams: tournament.teams,
                    tournament: tournament
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
    }
    
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.tournament?.name ?? "Tournament")
                        .font(.title2.bold())
                    
                    HStack(spacing: 16) {
                        Label("\(viewModel.tournament?.courts ?? 1) Courts", 
                              systemImage: "court.sport")
                        
                        Label("\(viewModel.tournament?.numberOfGroups ?? 2) Groups", 
                              systemImage: "rectangle.3.group")
                        
                        Label(viewModel.tournament?.setType.rawValue.capitalized ?? "Short", 
                              systemImage: "target")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    // Court assignment info
                    if let tournament = viewModel.tournament {
                        HStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.blue)
                            
                            Text(tournament.courtAssignmentStrategy.displayName)
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            if let suggestion = tournament.configurationSuggestion {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            if isReorderingEnabled {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    
                    Text("Drag matches to reorder the playing sequence")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    @ViewBuilder
    private var matchesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.groupedMatches.keys.sorted(), id: \.self) { groupId in
                    GroupMatchesSection(
                        groupId: groupId,
                        matches: viewModel.groupedMatches[groupId] ?? [],
                        teams: viewModel.tournament?.teams ?? [],
                        isReorderingEnabled: isReorderingEnabled,
                        onMatchTap: { match in
                            selectedMatch = match
                        },
                        onMatchReorder: { matches in
                            Task {
                                await viewModel.reorderMatches(matches)
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }
}

struct GroupMatchesSection: View {
    let groupId: String
    let matches: [Match]
    let teams: [Team]
    let isReorderingEnabled: Bool
    let onMatchTap: (Match) -> Void
    let onMatchReorder: ([Match]) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Group header
            HStack {
                Text("Group \(groupId)")
                    .font(.headline.bold())
                    .foregroundColor(groupColor)
                
                Spacer()
                
                Text("\(matches.count) matches")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(groupColor.opacity(0.1))
                    .foregroundColor(groupColor)
                    .cornerRadius(6)
            }
            
            // Matches list
            if isReorderingEnabled {
                ReorderableMatchesList(
                    matches: matches,
                    teams: teams,
                    groupColor: groupColor,
                    onReorder: onMatchReorder
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(matches.sorted { $0.round < $1.round }) { match in
                        MatchCard(
                            match: match,
                            teams: teams,
                            groupColor: groupColor,
                            isReorderingEnabled: false
                        ) {
                            onMatchTap(match)
                        }
                    }
                }
            }
        }
        .padding()
        .background(groupColor.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(groupColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var groupColor: Color {
        groupId == "A" ? .blue : .green
    }
}

struct ReorderableMatchesList: View {
    @State private var matches: [Match]
    let teams: [Team]
    let groupColor: Color
    let onReorder: ([Match]) -> Void
    
    init(matches: [Match], teams: [Team], groupColor: Color, onReorder: @escaping ([Match]) -> Void) {
        self._matches = State(initialValue: matches.sorted { $0.round < $1.round })
        self.teams = teams
        self.groupColor = groupColor
        self.onReorder = onReorder
    }
    
    var body: some View {
        List {
            ForEach(matches) { match in
                MatchCard(
                    match: match,
                    teams: teams,
                    groupColor: groupColor,
                    isReorderingEnabled: true
                ) {
                    // No action during reordering
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            .onMove { from, to in
                var newMatches = matches
                newMatches.move(fromOffsets: from, toOffset: to)
                matches = newMatches
                
                // Update round numbers based on new order
                for (index, _) in matches.enumerated() {
                    matches[index].round = index + 1
                }
                
                onReorder(matches)
            }
        }
        .listStyle(.plain)
        .frame(minHeight: CGFloat(matches.count * 100)) // Approximate height per match card
    }
}

struct MatchCard: View {
    let match: Match
    let teams: [Team]
    let groupColor: Color
    let isReorderingEnabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Round indicator
                VStack(spacing: 4) {
                    Text("R\(match.round)")
                        .font(.caption.bold())
                    
                    Text("C\(match.court)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 40)
                .padding(.vertical, 8)
                .background(groupColor.opacity(0.15))
                .cornerRadius(8)
                
                // Teams
                VStack(alignment: .leading, spacing: 6) {
                    teamRow(teamId: match.team1Id, score: match.score1)
                    
                    Divider()
                    
                    teamRow(teamId: match.team2Id, score: match.score2)
                }
                
                Spacer()
                
                // Status indicator
                VStack(spacing: 4) {
                    if match.isPlayed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        Text("Done")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "clock.circle")
                            .foregroundColor(.orange)
                            .font(.title3)
                        
                        Text("Pending")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                if isReorderingEnabled {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .disabled(isReorderingEnabled)
    }
    
    @ViewBuilder
    private func teamRow(teamId: String, score: Int?) -> some View {
        HStack {
            if let team = teams.first(where: { $0.id == teamId }) {
                Text(team.displayName)
                    .font(.subheadline.bold())
                
                Spacer()
                
                if let score = score {
                    Text("\(score)")
                        .font(.title3.bold())
                        .foregroundColor(isWinningScore(score) ? .primary : .secondary)
                }
            } else {
                Text("Unknown Team")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
    }
    
    private func isWinningScore(_ score: Int) -> Bool {
        guard let otherScore = match.score1 == score ? match.score2 : match.score1 else {
            return false
        }
        return score > otherScore
    }
}

#Preview {
    ScheduleView(tournamentId: "preview-tournament-id")
}
