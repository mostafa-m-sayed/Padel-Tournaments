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
            // Dead branch — resolveStrategy never returns .automatic — but
            // kept defensively. Mirror resolveStrategy's mapping.
            let resolved = resolveStrategy(tournament)
            return assignCourts(to: matches, tournament: tournament.withStrategy(resolved))
        }
    }
    
    // MARK: - Private Methods
    
    /// Assigns courts per group. When courts divide evenly across groups, each
    /// group receives a contiguous block of `courts / groupCount` courts and
    /// its matches are distributed across that block. Otherwise falls back to
    /// the legacy single-court-per-group assignment.
    /// Knockout matches (groupId == nil) are always distributed across all
    /// courts so finals/semis can run in parallel without being confined to a
    /// single group's block.
    private static func assignCourtsPerGroup(
        matches: [Match],
        tournament: Tournament
    ) -> [Match] {
        let knockoutMatches = matches.filter { $0.groupId == nil }
        let groupStageMatches = matches.filter { $0.groupId != nil }
        let groupedMatches = Dictionary(grouping: groupStageMatches) { $0.groupId ?? "" }
        let sortedGroupIds = groupedMatches.keys.sorted()
        let groupCount = sortedGroupIds.count
        let courts = tournament.courts

        var updatedMatches: [Match] = []

        if groupCount > 0 && courts >= groupCount && courts % groupCount == 0 {
            let courtsPerGroup = courts / groupCount

            for (groupIndex, groupId) in sortedGroupIds.enumerated() {
                let groupMatches = groupedMatches[groupId] ?? []
                let startCourt = groupIndex * courtsPerGroup + 1
                let endCourt = startCourt + courtsPerGroup - 1

                // Distribute the group's matches across its court block in
                // round order so concurrent matches in the same round land on
                // distinct courts within the block.
                let sortedMatches = groupMatches.sorted { $0.round < $1.round }
                var nextCourt = startCourt
                for match in sortedMatches {
                    var updated = match
                    updated.court = nextCourt
                    updatedMatches.append(updated)
                    nextCourt = nextCourt < endCourt ? nextCourt + 1 : startCourt
                }
            }
        } else {
            // Legacy single-court-per-group fallback (more groups than courts,
            // or uneven division).
            for (groupIndex, groupId) in sortedGroupIds.enumerated() {
                let groupMatches = groupedMatches[groupId] ?? []
                let assignedCourt = courts > 0 ? (groupIndex % courts) + 1 : 1
                for match in groupMatches {
                    var updated = match
                    updated.court = assignedCourt
                    updatedMatches.append(updated)
                }
            }
        }

        if !knockoutMatches.isEmpty {
            let distributed = distributeMatchesAcrossCourts(
                matches: knockoutMatches,
                tournament: tournament
            )
            updatedMatches.append(contentsOf: distributed)
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
            // Prefer per-group when courts divide evenly across groups so each
            // group gets its own dedicated block of courts.
            if tournament.numberOfGroups > 0
                && tournament.courts >= tournament.numberOfGroups
                && tournament.courts % tournament.numberOfGroups == 0 {
                return .perGroup
            }
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