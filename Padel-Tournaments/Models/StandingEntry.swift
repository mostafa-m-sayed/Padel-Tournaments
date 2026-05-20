//
//  StandingEntry.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//


struct StandingEntry: Identifiable {
    let id: String          // teamId
    var team: Team
    var wins: Int = 0
    var losses: Int = 0
    var pointsFor: Int = 0      // total games won across all matches
    var pointsAgainst: Int = 0

    var matchesPlayed: Int { wins + losses }

    // Tiebreaker priority: pointsFor → wins → fewest losses
    static func sorted(_ entries: [StandingEntry]) -> [StandingEntry] {
        entries.sorted {
            if $0.pointsFor != $1.pointsFor { return $0.pointsFor > $1.pointsFor }
            if $0.wins != $1.wins         { return $0.wins > $1.wins }
            return $0.losses < $1.losses
        }
    }
}
