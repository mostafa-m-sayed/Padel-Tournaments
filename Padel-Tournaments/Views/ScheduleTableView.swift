//
//  ScheduleTableView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI



struct ScheduleTableView: View {
    let tournamentId: String
    @StateObject private var viewModel: ScheduleViewModel
    @State private var selectedGroup: String = "All"
    @Environment(\.dismiss) private var dismiss
    
    init(tournamentId: String) {
        self.tournamentId = tournamentId
        self._viewModel = StateObject(wrappedValue: ScheduleViewModel(tournamentId: tournamentId))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Group selector
                groupSelectorView
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading tournament...")
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    ErrorView(
                        error: error,
                        retryAction: {
                            Task { await viewModel.loadTournament() }
                        }
                    )
                    Spacer()
                } else {
                    // Schedule table
                    scheduleTableView
                }
            }
            .navigationTitle("Schedule Table")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Export as PDF") {
                            // TODO: Implement PDF export
                            print("Export as PDF")
                        }
                        
                        Button("Share Schedule") {
                            // TODO: Implement sharing
                            print("Share schedule")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .task {
            await viewModel.loadTournament()
        }
        .onAppear {
            // Set default to first available group
            if selectedGroup == "All", let firstGroup = availableGroups.first {
                selectedGroup = firstGroup
            }
        }
        .onChange(of: selectedGroup) { newValue in
            // Debug: Print match counts
            if let matches = viewModel.groupedMatches[newValue] {
                print("🔍 Group \(newValue): \(matches.count) matches")
                for match in matches.sorted(by: { $0.round < $1.round }) {
                    print("   Round \(match.round): \(match.team1Id) vs \(match.team2Id)")
                }
            } else if newValue == "All" {
                print("🔍 All Groups:")
                for (groupId, matches) in viewModel.groupedMatches {
                    print("   Group \(groupId): \(matches.count) matches")
                }
            }
        }
    }
    
    @ViewBuilder
    private var groupSelectorView: some View {
        VStack(spacing: 12) {
            // Tournament info
            if let tournament = viewModel.tournament {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tournament.name)
                            .font(.headline.bold())
                        
                        Text("\(tournament.courts) Courts • \(tournament.numberOfGroups) Groups")
                            .font(.caption)
                            .foregroundColor(Color.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            // Group picker
            Picker("Group", selection: $selectedGroup) {
                Text("All Groups").tag("All")
                
                ForEach(availableGroups, id: \.self) { group in
                    Text("Group \(group)").tag(group)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    @ViewBuilder
    private var scheduleTableView: some View {
        ScrollView([.horizontal, .vertical]) {
            LazyVStack(spacing: 0) {
                // Header row
                tableHeaderView
                
                // Match rows
                ForEach(filteredMatchesByRound, id: \.0) { round, matches in
                    MatchRoundRow(
                        round: round,
                        matches: matches,
                        courts: viewModel.tournament?.courts ?? 1,
                        teams: viewModel.tournament?.teams ?? [],
                        groupColor: groupColor(for: selectedGroup),
                        isShowingAllGroups: selectedGroup == "All"
                    )
                }
            }
        }
        .background(.regularMaterial)
    }
    
    @ViewBuilder
    private var tableHeaderView: some View {
        HStack(spacing: 0) {
            // Round column
            Text("Round")
                .font(.headline.bold())
                .frame(width: 80, height: 50, alignment: .center)
                .background(.quaternary)
            
            Divider()
            
            // Court columns
            ForEach(1...(viewModel.tournament?.courts ?? 1), id: \.self) { court in
                Text("Court \(court)")
                    .font(.headline.bold())
                    .frame(width: 220, height: 50, alignment: .center)
                    .background(.quaternary)
                
                if court < (viewModel.tournament?.courts ?? 1) {
                    Divider()
                }
            }
        }
        .overlay(
            Rectangle()
                .stroke(.separator, lineWidth: 1)
        )
    }
    
    private var availableGroups: [String] {
        Set(viewModel.groupedMatches.keys).sorted()
    }
    
    private var filteredMatches: [Match] {
        if selectedGroup == "All" {
            return viewModel.groupedMatches.values.flatMap { $0 }
        } else {
            return viewModel.groupedMatches[selectedGroup] ?? []
        }
    }
    
    private var filteredMatchesByRound: [(Int, [Match])] {
        if selectedGroup == "All" {
            // For "All Groups", we need to show all rounds from all groups
            let allMatches = viewModel.groupedMatches.values.flatMap { $0 }
            let sortedMatches = allMatches.sorted { $0.round < $1.round }
            
            // Find the maximum round number across all groups
            let maxRound = sortedMatches.map(\.round).max() ?? 1
            
            // Create entries for all rounds (1 to maxRound)
            var result: [(Int, [Match])] = []
            
            for round in 1...maxRound {
                let matchesInRound = sortedMatches.filter { $0.round == round }
                result.append((round, matchesInRound))
            }
            
            return result
        } else {
            // For individual groups, use the existing logic
            let matches = filteredMatches.sorted { $0.round < $1.round }
            let groupedByRound = Dictionary(grouping: matches) { $0.round }
            return groupedByRound.sorted { $0.key < $1.key }
        }
    }
    
    private func groupColor(for group: String) -> Color {
        switch group {
        case "A": return .blue
        case "B": return .green
        case "C": return .orange
        case "D": return .purple
        default: return .gray
        }
    }
}

struct MatchRoundRow: View {
    let round: Int
    let matches: [Match]
    let courts: Int
    let teams: [Team]
    let groupColor: Color
    let isShowingAllGroups: Bool
    
    init(round: Int, matches: [Match], courts: Int, teams: [Team], groupColor: Color, isShowingAllGroups: Bool = false) {
        self.round = round
        self.matches = matches
        self.courts = courts
        self.teams = teams
        self.groupColor = groupColor
        self.isShowingAllGroups = isShowingAllGroups
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Round number
            Text("\(round)")
                .font(.title3.bold())
                .frame(width: 80, height: 100, alignment: .center)
                .background(.background)
            
            Divider()
            
            // Court columns
            ForEach(1...courts, id: \.self) { court in
                courtColumnView(for: court)
                    .frame(width: 220, height: 100, alignment: .center)
                
                if court < courts {
                    Divider()
                }
            }
        }
        .overlay(
            Rectangle()
                .stroke(.separator, lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func courtColumnView(for court: Int) -> some View {
        let match = matches.first { $0.court == court }
        
        if let match = match {
            let cellColor = isShowingAllGroups ? colorForGroup(match.groupId ?? "") : groupColor
            MatchCell(match: match, teams: teams, groupColor: cellColor)
                .padding(8)
        } else {
            Text("—")
                .font(.title2)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
    
    private func colorForGroup(_ groupId: String) -> Color {
        switch groupId {
        case "A": return .blue
        case "B": return .green
        case "C": return .orange
        case "D": return .purple
        default: return .gray
        }
    }
}

struct MatchCell: View {
    let match: Match
    let teams: [Team]
    let groupColor: Color
    
    var body: some View {
        VStack(spacing: 4) {
            // Group indicator and status
            HStack {
                Text("Group \(match.groupId ?? "")")
                    .font(.caption2.bold())
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(groupColor.opacity(0.2))
                    .foregroundColor(groupColor)
                    .cornerRadius(3)
                
                Spacer()
                
                if match.isPlayed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.green)
                        .font(.caption2)
                }
            }
            
            Spacer(minLength: 2)
            
            // Teams
            VStack(spacing: 2) {
                teamRow(teamId: match.team1Id, score: match.score1)
                
                Text("vs")
                    .font(.caption2.bold())
                    .foregroundColor(Color.secondary)
                    .padding(.vertical, 1)
                
                teamRow(teamId: match.team2Id, score: match.score2)
            }
            
            Spacer(minLength: 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(6)
        .background(.regularMaterial)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(groupColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func teamRow(teamId: String, score: Int?) -> some View {
        HStack(spacing: 2) {
            if let team = teams.first(where: { $0.id == teamId }) {
                Text(team.displayName)
                    .font(.caption.bold())
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer(minLength: 2)
                
                if let score = score {
                    Text("\(score)")
                        .font(.caption.bold())
                        .foregroundColor(isWinningScore(score) ? Color.primary : Color.secondary)
                        .frame(minWidth: 16, alignment: .trailing)
                }
            } else {
                Text("TBD")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: 16) // Fixed height for consistency
    }
    
    private func isWinningScore(_ score: Int) -> Bool {
        guard let otherScore = match.score1 == score ? match.score2 : match.score1 else {
            return false
        }
        return score > otherScore
    }
}

#Preview {
    ScheduleTableView(tournamentId: "preview-tournament-id")
}
