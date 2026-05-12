//
//  Team.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//


struct Team: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var player1: Player
    var player2: Player

    var displayName: String { "\(player1.name) & \(player2.name)" }
}