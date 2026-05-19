//
//  CourtAssignmentManager.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation

struct CourtAssignmentManager {
    
    /// Assigns courts to matches based on the tournament's strategy and configuration
    static func assignCourts(
        to matches: [Match], 
        tournament: Tournament
    ) -> [Match] {
        let strategy = resolveStrategy(tournament)
        
        switch strategy {
        case .perGroup:
            return assignCourtsPerGroup(matches: matches, tournament: tournament)
        case .distributed:
            return distributeMatchesAcrossCourts(matches: matches, tournament: tournament)
        case .automatic:
            // Choose strategy based on groups vs courts ratio
            let optimalStrategy = tournament.numberOfGroups >= tournament.courts ? 
                CourtAssignmentStrategy.perGroup : 
                CourtAssignmentStrategy.distributed
            return assignCourts(to: matches, tournament: tournament.withStrategy(optimalStrategy))
        }
    }
    
    // MARK: - Private Methods
    
    /// Assigns one court per group
    private static func assignCourtsPerGroup(
        matches: [Match], 
        tournament: Tournament
    ) -> [Match] {
        let groupedMatches = Dictionary(grouping: matches) { $0.groupId ?? "Knockout" }
        var updatedMatches: [Match] = []
        
        for (groupIndex, groupId) in Array(groupedMatches.keys.sorted()).enumerated() {
            let groupMatches = groupedMatches[groupId] ?? []
            let assignedCourt = (groupIndex % tournament.courts) + 1
            
            for match in groupMatches {
                var updatedMatch = match
                updatedMatch.court = assignedCourt
                updatedMatches.append(updatedMatch)
            }
        }
        
        return updatedMatches
    }
    
    /// Distributes matches across all courts to minimize idle time
    private static func distributeMatchesAcrossCourts(
        matches: [Match], 
        tournament: Tournament
    ) -> [Match] {
        // Sort matches by round (playing order)
        let sortedMatches = matches.sorted { match1, match2 in
            if match1.round != match2.round {
                return match1.round < match2.round
            }
            // If same round, sort by group to keep group matches together when possible
            return (match1.groupId ?? "Z") < (match2.groupId ?? "Z")
        }
        
        // Track when each court will be free
        var courtAvailability: [Int: Int] = [:]  // court -> next available round
        for court in 1...tournament.courts {
            courtAvailability[court] = 1
        }
        
        var updatedMatches: [Match] = []
        
        for match in sortedMatches {
            // Find the court that will be available earliest
            let earliestCourt = courtAvailability.min { $0.value < $1.value }?.key ?? 1
            
            var updatedMatch = match
            updatedMatch.court = earliestCourt
            
            // Update court availability
            courtAvailability[earliestCourt] = match.round + 1
            
            updatedMatches.append(updatedMatch)
        }
        
        return updatedMatches
    }
    
    private static func resolveStrategy(_ tournament: Tournament) -> CourtAssignmentStrategy {
        switch tournament.courtAssignmentStrategy {
        case .automatic:
            return tournament.numberOfGroups >= tournament.courts ? .perGroup : .distributed
        case .perGroup, .distributed:
            return tournament.courtAssignmentStrategy
        }
    }
}

// MARK: - Tournament Extension

extension Tournament {
    func withStrategy(_ strategy: CourtAssignmentStrategy) -> Tournament {
        var updated = self
        updated.courtAssignmentStrategy = strategy
        return updated
    }
    
    /// Validates if the current configuration makes sense
    var isConfigurationValid: Bool {
        guard numberOfGroups > 0, courts > 0 else { return false }
        
        // For per-group strategy, warn if more groups than courts
        if courtAssignmentStrategy == .perGroup && numberOfGroups > courts {
            // Still valid, but some courts will handle multiple groups
            return true
        }
        
        return true
    }
    
    /// Provides suggestions for optimal configuration
    var configurationSuggestion: String? {
        if numberOfGroups > courts && courtAssignmentStrategy == .perGroup {
            return "Consider using 'Distributed' strategy or adding more courts for optimal court utilization."
        }
        
        if numberOfGroups < courts && courtAssignmentStrategy == .perGroup {
            return "Some courts may be idle. Consider 'Distributed' strategy for better court utilization."
        }
        
        return nil
    }
}