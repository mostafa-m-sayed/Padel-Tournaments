//
//  CreateTournamentViewModel.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation
import Combine

@MainActor
final class CreateTournamentViewModel: ObservableObject {
    @Published var currentStep: TournamentCreationStep = .basicInfo
    @Published var tournamentName = ""
    @Published var numberOfCourts = 1
    @Published var numberOfGroups = 2  // New: configurable number of groups
    @Published var courtAssignmentStrategy: CourtAssignmentStrategy = .automatic  // New: court assignment strategy
    @Published var setType: SetType = .short
    @Published var teams: [Team] = []
    @Published var groupA: [Team] = []
    @Published var groupB: [Team] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var createdTournamentId: String?
    
    private let tournamentRepository: TournamentRepositoryProtocol
    
    enum TournamentCreationStep {
        case basicInfo
        case teamSetup
        case groupAssignment
    }
    
    init(tournamentRepository: TournamentRepositoryProtocol = TournamentRepository()) {
        self.tournamentRepository = tournamentRepository
    }
    
    func nextStep() {
        switch currentStep {
        case .basicInfo:
            currentStep = .teamSetup
        case .teamSetup:
            if teams.count >= 4 {
                currentStep = .groupAssignment
            }
        case .groupAssignment:
            break // Final step
        }
    }
    
    func previousStep() {
        switch currentStep {
        case .basicInfo:
            break // First step
        case .teamSetup:
            currentStep = .basicInfo
        case .groupAssignment:
            currentStep = .teamSetup
        }
    }
    
    func addTeam(player1Name: String, player2Name: String) {
        let player1 = Player(id: UUID().uuidString, name: player1Name)
        let player2 = Player(id: UUID().uuidString, name: player2Name)
        let team = Team(
            id: UUID().uuidString,
            name: "\(player1Name) & \(player2Name)",
            player1: player1,
            player2: player2
        )
        teams.append(team)
    }
    
    func removeTeam(at index: Int) {
        guard index < teams.count else { return }
        let teamToRemove = teams[index]
        teams.remove(at: index)
        
        // Remove from groups if assigned
        groupA.removeAll { $0.id == teamToRemove.id }
        groupB.removeAll { $0.id == teamToRemove.id }
    }
    
    func assignTeamToGroup(_ team: Team, group: TournamentGroupType) {
        // Remove from both groups first
        groupA.removeAll { $0.id == team.id }
        groupB.removeAll { $0.id == team.id }
        
        // Add to selected group
        switch group {
        case .groupA:
            groupA.append(team)
        case .groupB:
            groupB.append(team)
        }
    }
    
    func randomizeGroups() {
        let shuffledTeams = teams.shuffled()
        groupA.removeAll()
        groupB.removeAll()
        
        for (index, team) in shuffledTeams.enumerated() {
            if index % 2 == 0 {
                groupA.append(team)
            } else {
                groupB.append(team)
            }
        }
    }
    
    func resetAllTeamsToUnassigned() {
        groupA.removeAll()
        groupB.removeAll()
    }
    
    func createTournament() async {
        isLoading = true
        error = nil
        
        print("🏆 Starting tournament creation...")
        
        // Create groups using the manually assigned teams from groupA and groupB
        let groups = createGroups()
        
        // Generate matches using ScheduleEngine
        let matches = ScheduleEngine.generateMatches(
            groups: groups,
            courts: numberOfCourts
        )
        
        // Apply court assignment strategy
        let tournamentId = generateShortTournamentId()
        let tournament = Tournament(
            id: tournamentId,
            name: tournamentName,
            courts: numberOfCourts,
            numberOfGroups: numberOfGroups,
            setType: setType,
            status: .groupStage, // Start in group stage once created
            createdAt: Date(),
            courtAssignmentStrategy: courtAssignmentStrategy
        )
        
        // Assign courts to matches
        let matchesWithCourts = CourtAssignmentManager.assignCourts(
            to: matches,
            tournament: tournament
        )
        
        do {
            try await tournamentRepository.createTournamentWithSubcollections(
                tournament, 
                teams: teams, 
                groups: groups, 
                matches: matchesWithCourts
            )
            print("✅ Tournament created successfully with ID: \(tournamentId)")
            createdTournamentId = tournamentId
        } catch {
            print("❌ Failed to create tournament: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    /// Creates groups using the manually assigned teams from groupA and groupB
    private func createGroups() -> [TournamentGroup] {
        var groups: [TournamentGroup] = []
        
        // Create Group A with manually assigned teams
        if !groupA.isEmpty {
            groups.append(TournamentGroup(
                id: "A",
                name: "A",
                teamIds: groupA.map { $0.id }
            ))
        }
        
        // Create Group B with manually assigned teams
        if !groupB.isEmpty {
            groups.append(TournamentGroup(
                id: "B",
                name: "B", 
                teamIds: groupB.map { $0.id }
            ))
        }
        
        return groups
    }
    
    var canProceedFromBasicInfo: Bool {
        !tournamentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var canProceedFromTeamSetup: Bool {
        teams.count >= 4 && teams.count % 2 == 0
    }
    
    var canCreateTournament: Bool {
        // All teams must be assigned to groups
        let allTeamsAssigned = unassignedTeams.isEmpty
        // Both groups must have teams
        let bothGroupsHaveTeams = !groupA.isEmpty && !groupB.isEmpty
        // Groups must have equal number of teams
        let equalGroups = groupA.count == groupB.count
        
        return allTeamsAssigned && bothGroupsHaveTeams && equalGroups
    }
    
    var unassignedTeams: [Team] {
        let assignedTeamIds = Set(groupA.map { $0.id } + groupB.map { $0.id })
        return teams.filter { !assignedTeamIds.contains($0.id) }
    }
    
    // MARK: - Helper Methods
    
    /// Generates a short, user-friendly tournament ID (e.g., "PD2024A7")
    private func generateShortTournamentId() -> String {
        let prefix = "PD" // Padel identifier
        let year = String(Date().year).suffix(4)
        let randomString = String((0..<4).map { _ in
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()!
        })
        
        return "\(prefix)\(year)\(randomString)"
    }
}

// Helper extension for Date
private extension Date {
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
}

enum TournamentGroupType {
    case groupA
    case groupB
}
