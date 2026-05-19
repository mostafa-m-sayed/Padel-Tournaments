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
    
    func assignTeamToGroup(_ team: Team, group: TournamentGroup) {
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
        
        // Create groups dynamically based on numberOfGroups
        let groups = createGroups()
        
        // Generate matches using ScheduleEngine
        let matches = ScheduleEngine.generateMatches(
            groups: groups,
            courts: numberOfCourts
        )
        
        // Apply court assignment strategy
        let tournamentId = UUID().uuidString
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
            createdTournamentId = tournamentId
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    /// Creates groups dynamically based on numberOfGroups
    private func createGroups() -> [Group] {
        let groupNames = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ".prefix(numberOfGroups))
        var groups: [Group] = []
        
        // Distribute teams evenly across groups
        let shuffledTeams = teams.shuffled()
        let teamsPerGroup = teams.count / numberOfGroups
        let extraTeams = teams.count % numberOfGroups
        
        for (index, groupName) in groupNames.enumerated() {
            let startIndex = index * teamsPerGroup + min(index, extraTeams)
            let endIndex = startIndex + teamsPerGroup + (index < extraTeams ? 1 : 0)
            
            let groupTeams = Array(shuffledTeams[startIndex..<endIndex])
            groups.append(Group(
                id: String(groupName),
                name: String(groupName),
                teamIds: groupTeams.map { $0.id }
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
        !groupA.isEmpty && !groupB.isEmpty && groupA.count == groupB.count
    }
    
    var unassignedTeams: [Team] {
        let assignedTeamIds = Set(groupA.map { $0.id } + groupB.map { $0.id })
        return teams.filter { !assignedTeamIds.contains($0.id) }
    }
}

enum TournamentGroup {
    case groupA
    case groupB
}
