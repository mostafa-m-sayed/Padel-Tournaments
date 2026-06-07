//
//  TournamentProgressionManager.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation

protocol TournamentProgressionManagerProtocol {
    func isGroupStageComplete(tournament: Tournament) -> Bool
    func canAdvanceToKnockout(tournament: Tournament) -> Bool
    func generateKnockoutMatches(from tournament: Tournament, topTeamsPerGroup: [String: [StandingEntry]]) -> [Match]
    func advanceToKnockoutStage(tournament: Tournament, topTeamsPerGroup: [String: [StandingEntry]]) async throws -> Tournament
    func updateBracketMatches(tournament: Tournament) async throws -> Tournament
}

final class TournamentProgressionManager: TournamentProgressionManagerProtocol {
    private let tournamentRepository: TournamentRepositoryProtocol
    
    init(tournamentRepository: TournamentRepositoryProtocol = TournamentRepository()) {
        self.tournamentRepository = tournamentRepository
    }
    
    // MARK: - Group Stage Completion Detection
    
    func isGroupStageComplete(tournament: Tournament) -> Bool {
        guard tournament.status == .groupStage else { return false }
        
        // Check if all group stage matches are played
        let groupMatches = tournament.matches.filter { $0.stage == .group }
        let playedGroupMatches = groupMatches.filter { $0.isPlayed }
        
        return groupMatches.count > 0 && playedGroupMatches.count == groupMatches.count
    }
    
    func canAdvanceToKnockout(tournament: Tournament) -> Bool {
        guard isGroupStageComplete(tournament: tournament) else { return false }
        
        // Ensure we have at least 2 groups and 4 teams total to create semifinals
        let totalTeams = tournament.teams.count
        let numberOfGroups = tournament.groups.count
        return totalTeams >= 4 && numberOfGroups >= 2
    }
    
    // MARK: - Knockout Match Generation
    
    func generateKnockoutMatches(from tournament: Tournament, topTeamsPerGroup: [String: [StandingEntry]]) -> [Match] {
        var knockoutMatches: [Match] = []
        
        // Validate we have enough qualified teams
        let totalQualifiedTeams = topTeamsPerGroup.values.flatMap { Array($0.prefix(2)) }.count
        
        guard totalQualifiedTeams >= 4 else {
            print("❌ Not enough qualified teams for knockout stage: \(totalQualifiedTeams)")
            return []
        }
        
        // Generate semifinals with seeding
        let semiMatches = generateSemifinalsWithProperSeeding(topTeamsPerGroup: topTeamsPerGroup, courts: tournament.courts)
        knockoutMatches.append(contentsOf: semiMatches)
        
        // Generate third place playoff (will be populated after semifinals)
        let thirdPlaceMatch = generateThirdPlacePlayoff(courts: tournament.courts)
        knockoutMatches.append(thirdPlaceMatch)
        
        // Generate final match (will be populated after semifinals)
        let finalMatch = generateFinalMatch(courts: tournament.courts)
        knockoutMatches.append(finalMatch)
        
        return knockoutMatches
    }
    
    // MARK: - Tournament Status Update
    
    func advanceToKnockoutStage(tournament: Tournament, topTeamsPerGroup: [String: [StandingEntry]]) async throws -> Tournament {
        guard canAdvanceToKnockout(tournament: tournament) else {
            throw NetworkError.serverError("Cannot advance to knockout stage: group stage not complete or insufficient teams")
        }
        
        // Generate knockout matches
        let knockoutMatches = generateKnockoutMatches(from: tournament, topTeamsPerGroup: topTeamsPerGroup)
        
        // Update tournament with new matches and status
        var updatedTournament = tournament
        updatedTournament.matches.append(contentsOf: knockoutMatches)
        updatedTournament.status = .knockout
        
        // Save to repository
        try await tournamentRepository.updateTournament(updatedTournament)
        try await tournamentRepository.updateMatches(tournamentId: tournament.id, matches: updatedTournament.matches)
        
        print("🏆 Tournament advanced to knockout stage with \(knockoutMatches.count) new matches")
        
        return updatedTournament
    }
    
    // MARK: - Private Helper Methods
    
    private func generateThirdPlacePlayoff(courts: Int) -> Match {
        // Placeholder match - team IDs will be populated after semifinals
        return Match(
            id: UUID().uuidString,
            court: 1,
            round: 2,
            stage: .thirdPlace,
            team1Id: "TBD_SEMI1_LOSER",  // Will be updated after semi 1
            team2Id: "TBD_SEMI2_LOSER",  // Will be updated after semi 2
            score1: nil,
            score2: nil,
            groupId: nil
        )
    }
    
    private func generateFinalMatch(courts: Int) -> Match {
        // Placeholder match - team IDs will be populated after semifinals
        return Match(
            id: UUID().uuidString,
            court: 1,
            round: 3,
            stage: .final,
            team1Id: "TBD_SEMI1_WINNER", // Will be updated after semi 1
            team2Id: "TBD_SEMI2_WINNER", // Will be updated after semi 2
            score1: nil,
            score2: nil,
            groupId: nil
        )
    }
}

// MARK: - Extensions for better seeding

extension TournamentProgressionManager {
    
    /// Improved seeding for tournaments with exactly 2 groups
    private func generateSemifinalsWithProperSeeding(topTeamsPerGroup: [String: [StandingEntry]], courts: Int) -> [Match] {
        let sortedGroups = topTeamsPerGroup.keys.sorted()
        guard sortedGroups.count == 2,
              let groupAStandings = topTeamsPerGroup[sortedGroups[0]],
              let groupBStandings = topTeamsPerGroup[sortedGroups[1]],
              groupAStandings.count >= 2,
              groupBStandings.count >= 2 else {
            print("❌ Invalid group structure for seeding")
            return []
        }
        
        let groupAWinner = groupAStandings[0]
        let groupARunnerUp = groupAStandings[1]
        let groupBWinner = groupBStandings[0]
        let groupBRunnerUp = groupBStandings[1]
        
        // Proper seeding: Group A winner vs Group B runner-up, Group B winner vs Group A runner-up
        let semi1 = Match(
            id: UUID().uuidString,
            court: 1,
            round: 1,
            stage: .semi,
            team1Id: groupAWinner.id,
            team2Id: groupBRunnerUp.id,
            score1: nil,
            score2: nil,
            groupId: nil
        )
        
        let semi2 = Match(
            id: UUID().uuidString,
            court: min(2, courts),
            round: 1,
            stage: .semi,
            team1Id: groupBWinner.id,
            team2Id: groupARunnerUp.id,
            score1: nil,
            score2: nil,
            groupId: nil
        )
        
        print("🏆 Generated semifinals with proper seeding:")
        print("   Semi 1: \(groupAWinner.team.displayName) vs \(groupBRunnerUp.team.displayName)")
        print("   Semi 2: \(groupBWinner.team.displayName) vs \(groupARunnerUp.team.displayName)")
        
        return [semi1, semi2]
    }
    
    /// Updates bracket matches when semifinals are completed
    func updateBracketMatches(tournament: Tournament) async throws -> Tournament {
        guard tournament.status == .knockout else { return tournament }
        
        let semiMatches = tournament.matches.filter { $0.stage == .semi && $0.isPlayed }
        guard semiMatches.count == 2 else { return tournament } // Not ready yet
        
        var updatedTournament = tournament
        var updatedMatches = tournament.matches
        
        // Get winners and losers from semifinals (both have round 1, so use different identification)
        let semi1 = semiMatches[0]
        let semi2 = semiMatches[1]
        
        guard let semi1Winner = semi1.winnerId,
              let semi1Loser = semi1.loserId,
              let semi2Winner = semi2.winnerId,
              let semi2Loser = semi2.loserId else {
            print("❌ Semifinals don't have clear winners/losers")
            return tournament
        }
        
        // Update final match
        if let finalIndex = updatedMatches.firstIndex(where: { $0.stage == .final }) {
            updatedMatches[finalIndex].team1Id = semi1Winner
            updatedMatches[finalIndex].team2Id = semi2Winner
        }
        
        // Update third place match
        if let thirdPlaceIndex = updatedMatches.firstIndex(where: { $0.stage == .thirdPlace }) {
            updatedMatches[thirdPlaceIndex].team1Id = semi1Loser
            updatedMatches[thirdPlaceIndex].team2Id = semi2Loser
        }
        
        updatedTournament.matches = updatedMatches
        
        // Save to repository
        try await tournamentRepository.updateMatches(tournamentId: tournament.id, matches: updatedMatches)
        
        print("🏆 Updated bracket matches: Final and Third Place matches are now ready")
        
        return updatedTournament
    }
}