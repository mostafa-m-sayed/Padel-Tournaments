//
//  TournamentGroup.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//


struct TournamentGroup: Identifiable, Codable {
    let id: String
    var name: String        // "A" or "B"
    var teamIds: [String]

    func teams(from allTeams: [Team]) -> [Team] {
        allTeams.filter { teamIds.contains($0.id) }
    }
}
