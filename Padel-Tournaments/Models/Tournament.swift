//
//  Tournament.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation

struct Tournament: Identifiable, Codable {
    let id: String
    var name: String
    var courts: Int
    var numberOfGroups: Int  // New: configurable number of groups
    var setType: SetType
    var status: TournamentStatus
    var createdAt: Date
    var courtAssignmentStrategy: CourtAssignmentStrategy  // New: how to assign courts

    // Not stored in this document — fetched as subcollections
    // kept here for in-memory convenience after loading
    var teams: [Team] = []
    var groups: [TournamentGroup] = []
    var matches: [Match] = []
}

enum CourtAssignmentStrategy: String, Codable, CaseIterable {
    case perGroup = "per_group"           // Each group gets a dedicated court
    case distributed = "distributed"      // Distribute matches across all courts
    case automatic = "automatic"          // System decides based on groups vs courts ratio
    
    var displayName: String {
        switch self {
        case .perGroup: return "One Court per Group"
        case .distributed: return "Distribute Across Courts"
        case .automatic: return "Automatic"
        }
    }
}
