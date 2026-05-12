//
//  TournamentRepository.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation

protocol TournamentRepositoryProtocol {
    func getAllTournaments() async throws -> [Tournament]
    func createTournament(_ tournament: Tournament) async throws
    func updateTournament(_ tournament: Tournament) async throws
    func deleteTournament(id: String) async throws
    func joinTournament(tournamentId: String, team: Team) async throws
}

final class TournamentRepository: TournamentRepositoryProtocol {
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func getAllTournaments() async throws -> [Tournament] {
        return try await networkManager.fetchTournaments()
    }
    
    func createTournament(_ tournament: Tournament) async throws {
        try await networkManager.createTournament(tournament)
    }
    
    func updateTournament(_ tournament: Tournament) async throws {
        try await networkManager.updateTournament(tournament)
    }
    
    func deleteTournament(id: String) async throws {
        try await networkManager.deleteTournament(id: id)
    }
    
    func joinTournament(tournamentId: String, team: Team) async throws {
        try await networkManager.joinTournament(tournamentId: tournamentId, team: team)
    }
}