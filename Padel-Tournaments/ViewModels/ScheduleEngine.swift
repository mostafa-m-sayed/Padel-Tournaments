//
//  ScheduleEngine.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation

struct ScheduleEngine {
    
    /// Generates matches for groups in a round-robin format
    static func generateMatches(groups: [Group], courts: Int) -> [Match] {
        var allMatches: [Match] = []
        
        for group in groups {
            let groupMatches = generateRoundRobinMatches(
                groupId: group.id,
                teamIds: group.teamIds
            )
            allMatches.append(contentsOf: groupMatches)
        }
        
        // Schedule matches across rounds to utilize all courts
        return scheduleMatchesAcrossRounds(allMatches, courts: courts)
    }
    
    /// Legacy method for backward compatibility
    static func generateMatches(groupA: [Team], groupB: [Team], courts: Int) -> [Match] {
        let groups = [
            Group(id: "A", name: "A", teamIds: groupA.map { $0.id }),
            Group(id: "B", name: "B", teamIds: groupB.map { $0.id })
        ]
        
        return generateMatches(groups: groups, courts: courts)
    }
    
    // MARK: - Private Methods
    
    private static func generateRoundRobinMatches(groupId: String, teamIds: [String]) -> [Match] {
        guard teamIds.count >= 2 else { return [] }
        
        var matches: [Match] = []
        
        // Generate all possible pairings (round-robin)
        for i in 0..<teamIds.count {
            for j in (i + 1)..<teamIds.count {
                let match = Match(
                    id: UUID().uuidString,
                    court: 1, // Will be reassigned by scheduling algorithm
                    round: 1, // Will be reassigned by scheduling algorithm
                    stage: .group,
                    team1Id: teamIds[i],
                    team2Id: teamIds[j],
                    score1: nil,
                    score2: nil,
                    groupId: groupId
                )
                matches.append(match)
            }
        }
        
        return matches
    }
    
    /// Schedules matches across rounds to maximize court utilization
    private static func scheduleMatchesAcrossRounds(_ matches: [Match], courts: Int) -> [Match] {
        // Group matches by groupId first
        let matchesByGroup = Dictionary(grouping: matches) { $0.groupId ?? "Knockout" }
        
        var allScheduledMatches: [Match] = []
        
        // Schedule each group independently
        for (_, groupMatches) in matchesByGroup {
            let scheduledGroupMatches = scheduleGroupMatches(groupMatches, courts: courts)
            allScheduledMatches.append(contentsOf: scheduledGroupMatches)
        }
        
        return allScheduledMatches
    }
    
    /// Schedules matches for a single group across rounds
    private static func scheduleGroupMatches(_ matches: [Match], courts: Int) -> [Match] {
        var scheduledMatches: [Match] = []
        var teamBusyInRound: [Int: Set<String>] = [:] // round -> set of busy team IDs
        
        for match in matches {
            var assignedRound = 1
            
            // Find the earliest round where both teams are available
            while let busyTeams = teamBusyInRound[assignedRound],
                  (busyTeams.contains(match.team1Id) || busyTeams.contains(match.team2Id)) {
                assignedRound += 1
            }
            
            // Check if this round already has the maximum number of matches for this group
            let matchesInRound = scheduledMatches.filter { $0.round == assignedRound }.count
            if matchesInRound >= courts {
                assignedRound += 1
            }
            
            // Assign the match to this round
            var updatedMatch = match
            updatedMatch.round = assignedRound
            scheduledMatches.append(updatedMatch)
            
            // Mark both teams as busy in this round
            if teamBusyInRound[assignedRound] == nil {
                teamBusyInRound[assignedRound] = Set()
            }
            teamBusyInRound[assignedRound]?.insert(match.team1Id)
            teamBusyInRound[assignedRound]?.insert(match.team2Id)
        }
        
        return scheduledMatches
    }
}