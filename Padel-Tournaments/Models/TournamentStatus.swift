//
//  TournamentStatus.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//


enum TournamentStatus: String, Codable {
    case setup          // organizer is building teams/groups
    case groupStage     // round robin in progress
    case knockout       // semis, 3rd place, final
    case finished       // champion decided
}
