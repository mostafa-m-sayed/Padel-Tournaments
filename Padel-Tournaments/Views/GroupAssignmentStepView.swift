//
//  GroupAssignmentStepView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct GroupAssignmentStepView: View {
    @ObservedObject var viewModel: CreateTournamentViewModel
    @State private var draggedTeam: Team?
    @State private var isRandomizing = false
    @State private var isReverting = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with randomize button
            VStack(spacing: 12) {
                HStack {
                    Text("Assign Groups")
                        .font(.title2.bold())
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button {
                            revertWithAnimation()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: isReverting ? "arrow.triangle.2.circlepath" : "arrow.counterclockwise")
                                    .font(.caption)
                                Text("Reset")
                                    .font(.caption.bold())
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .disabled(isRandomizing || isReverting || (viewModel.groupA.isEmpty && viewModel.groupB.isEmpty))
                        .rotationEffect(.degrees(isReverting ? -360 : 0))
                        
                        Button {
                            randomizeWithAnimation()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: isRandomizing ? "arrow.triangle.2.circlepath" : "shuffle")
                                    .font(.caption)
                                Text("Randomize")
                                    .font(.caption.bold())
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .disabled(isRandomizing || isReverting)
                    }
                    .rotationEffect(.degrees(isRandomizing ? 360 : 0))
                }
                
                if !viewModel.canCreateTournament {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            if !viewModel.unassignedTeams.isEmpty {
                                Text("All teams must be assigned to groups")
                            }
                            if viewModel.groupA.isEmpty || viewModel.groupB.isEmpty {
                                Text("Both groups must have at least one team")
                            }
                            if !viewModel.groupA.isEmpty && !viewModel.groupB.isEmpty && viewModel.groupA.count != viewModel.groupB.count {
                                Text("Groups must have equal number of teams")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // Groups and unassigned teams
            ScrollView {
                VStack(spacing: 20) {
                    // Groups
                    HStack(spacing: 16) {
                        GroupColumnView(
                            title: "Group A",
                            teams: viewModel.groupA,
                            color: .blue,
                            draggedTeam: draggedTeam
                        ) { team in
                            withAnimation(.spring()) {
                                viewModel.assignTeamToGroup(team, group: .groupA)
                            }
                        }
                        
                        GroupColumnView(
                            title: "Group B",
                            teams: viewModel.groupB,
                            color: .green,
                            draggedTeam: draggedTeam
                        ) { team in
                            withAnimation(.spring()) {
                                viewModel.assignTeamToGroup(team, group: .groupB)
                            }
                        }
                    }
                    
                    // Unassigned teams
                    if !viewModel.unassignedTeams.isEmpty {
                        UnassignedTeamsView(
                            teams: viewModel.unassignedTeams,
                            draggedTeam: $draggedTeam,
                            onTeamTap: { team in
                                // Auto-assign to group with fewer teams
                                let targetGroup: TournamentGroupType = viewModel.groupA.count <= viewModel.groupB.count ? .groupA : .groupB
                                withAnimation(.spring()) {
                                    viewModel.assignTeamToGroup(team, group: targetGroup)
                                }
                            }
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    private func randomizeWithAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isRandomizing = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                viewModel.randomizeGroups()
            }
            
            withAnimation(.easeInOut(duration: 0.3).delay(0.5)) {
                isRandomizing = false
            }
        }
    }
    
    private func revertWithAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isReverting = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                viewModel.resetAllTeamsToUnassigned()
            }
            
            withAnimation(.easeInOut(duration: 0.3).delay(0.5)) {
                isReverting = false
            }
        }
    }
}

struct GroupColumnView: View {
    let title: String
    let teams: [Team]
    let color: Color
    let draggedTeam: Team?
    let onTeamDropped: (Team) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(teams.count)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .foregroundColor(color)
                    .cornerRadius(6)
            }
            
            // Teams
            LazyVStack(spacing: 8) {
                ForEach(teams) { team in
                    GroupTeamCard(team: team, color: color)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            
            // Drop zone when empty or dragging
            if teams.isEmpty || draggedTeam != nil {
                DropZone(color: color, isEmpty: teams.isEmpty)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 200)
        .background(color.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .onDrop(of: [.text], isTargeted: nil) { providers in
            handleDrop(providers: providers)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let draggedTeam = draggedTeam else { return false }
        onTeamDropped(draggedTeam)
        return true
    }
}

// Team card already assigned in a group
struct GroupTeamCard: View {
    let team: Team
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(team.displayName)
                .font(.subheadline.bold())
            
            HStack {
                Text(team.player1.name)
                Text("•")
                Text(team.player2.name)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.defaultBg)
        .cornerRadius(12)
        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

struct UnassignedTeamsView: View {
    let teams: [Team]
    @Binding var draggedTeam: Team?
    let onTeamTap: (Team) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Unassigned Teams")
                    .font(.headline.bold())
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text("\(teams.count)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(6)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(teams) { team in
                    DraggableTeamCard(team: team, draggedTeam: $draggedTeam) {
                        onTeamTap(team)
                    }
                }
            }
        }
        .padding()
        .background(.orange.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

// Team card before assigning
struct DraggableTeamCard: View {
    let team: Team
    @Binding var draggedTeam: Team?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Text(team.displayName)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(team.player1.name)
                    Text(team.player2.name)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.defaultBg)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .scaleEffect(draggedTeam?.id == team.id ? 0.95 : 1.0)
            .opacity(draggedTeam?.id == team.id ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
        .onDrag {
            draggedTeam = team
            return NSItemProvider(object: team.id as NSString)
        }
    }
}

struct DropZone: View {
    let color: Color
    let isEmpty: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: isEmpty ? "plus.circle.dashed" : "arrow.down.circle.dashed")
                .font(.title)
                .foregroundColor(color.opacity(0.6))
            
            Text(isEmpty ? "Drop teams here" : "Drop to add")
                .font(.caption)
                .foregroundColor(color.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
        )
    }
}

#Preview {
    GroupAssignmentStepView(viewModel: {
        let vm = CreateTournamentViewModel()
        vm.addTeam(player1Name: "Alice", player2Name: "Bob")
        vm.addTeam(player1Name: "Charlie", player2Name: "David")
        vm.addTeam(player1Name: "Eve", player2Name: "Frank")
        vm.addTeam(player1Name: "Grace", player2Name: "Henry")
        return vm
    }())
}
