//
//  TournamentListViewModel.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation
import Combine
@MainActor
final class TournamentListViewModel: ObservableObject {
    @Published var tournaments: [Tournament] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let tournamentRepository: TournamentRepositoryProtocol
    
    init(tournamentRepository: TournamentRepositoryProtocol = TournamentRepository()) {
        self.tournamentRepository = tournamentRepository
    }
    
    func loadTournaments() async {
        isLoading = true
        error = nil
        
        do {
            tournaments = try await tournamentRepository.getAllTournaments()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func deleteTournament(at indexSet: IndexSet) async {
        for index in indexSet {
            let tournament = tournaments[index]
            do {
                try await tournamentRepository.deleteTournament(id: tournament.id)
                tournaments.remove(at: index)
            } catch {
                self.error = error
            }
        }
    }
    
    func refreshTournaments() async {
        await loadTournaments()
    }
    
    func clearError() {
        error = nil
    }
}
