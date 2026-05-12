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
    var setType: SetType
    var status: TournamentStatus
    var createdAt: Date

    // Not stored in this document — fetched as subcollections
    // kept here for in-memory convenience after loading
    var teams: [Team] = []
    var groups: [Group] = []
    var matches: [Match] = []
}
