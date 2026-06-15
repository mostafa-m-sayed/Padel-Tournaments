//
//  JoinTournamentViewModel.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation
import Combine

@MainActor
final class JoinTournamentViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    @Published var foundTournament: Tournament?
    
    private let tournamentRepository: TournamentRepositoryProtocol
    
    init(tournamentRepository: TournamentRepositoryProtocol = TournamentRepository()) {
        self.tournamentRepository = tournamentRepository
    }
    
    func joinTournament(id: String) async {
        isLoading = true
        error = nil
        foundTournament = nil
        
        do {
            print("🔍 Searching for tournament with ID: \(id)")
            let tournament = try await tournamentRepository.fetchTournamentDetails(id: id)
            
            print("✅ Tournament found: \(tournament.name)")
            foundTournament = tournament
            
        } catch {
            print("❌ Failed to join tournament: \(error)")
            
            // Provide user-friendly error messages
            if error is NetworkError {
                self.error = error
            } else {
                // Generic error handling for other types
                self.error = NetworkError.documentNotFound
            }
        }
        
        isLoading = false
    }
    
    func clearError() {
        error = nil
    }
}