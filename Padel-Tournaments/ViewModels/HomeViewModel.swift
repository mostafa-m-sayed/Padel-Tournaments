//
//  HomeViewModel.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showCreateTournament = false
    @Published var showJoinTournament = false
    
    private let tournamentRepository: TournamentRepositoryProtocol
    
    init(tournamentRepository: TournamentRepositoryProtocol = TournamentRepository()) {
        self.tournamentRepository = tournamentRepository
    }
    
    func createTournamentTapped() {
        showCreateTournament = true
    }
    
    func joinTournamentTapped() {
        showJoinTournament = true
    }
    
    func viewTournamentsTapped() {
        // Navigation will be handled by the view
    }
    
    func clearError() {
        error = nil
    }
}
