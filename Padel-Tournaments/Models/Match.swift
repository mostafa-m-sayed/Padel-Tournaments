//
//  Match.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//


struct Match: Identifiable, Codable {
    let id: String
    var court: Int
    var round: Int          // display order within a stage
    var stage: MatchStage
    var team1Id: String
    var team2Id: String
    var score1: Int?        // nil = not played yet
    var score2: Int?
    var groupId: String?    // nil for knockout matches

    var isPlayed: Bool { score1 != nil && score2 != nil }

    var winnerId: String? {
        guard let s1 = score1, let s2 = score2 else { return nil }
        if s1 > s2 { return team1Id }
        if s2 > s1 { return team2Id }
        return nil  // draw — shouldn't happen in padel but safe to handle
    }

    var loserId: String? {
        guard let w = winnerId else { return nil }
        return w == team1Id ? team2Id : team1Id
    }
}