//
//  ScheduleViewModel.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Combine

@MainActor
final class ScheduleViewModel: ObservableObject {
    @Published var tournament: Tournament?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showTableView = false
    
    private let tournamentId: String
    private let tournamentRepository: TournamentRepositoryProtocol
    
    init(tournamentId: String, tournamentRepository: TournamentRepositoryProtocol) {
        self.tournamentId = tournamentId
        self.tournamentRepository = tournamentRepository
    }
    
    convenience init(tournamentId: String) {
        self.init(tournamentId: tournamentId, tournamentRepository: TournamentRepository())
    }
    
    func loadTournament() async {
        isLoading = true
        error = nil
        
        do {
            tournament = try await tournamentRepository.fetchTournamentDetails(id: tournamentId)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func reorderMatches(_ newMatches: [Match]) async {
        guard let tournament = tournament else { return }
        
        // Reassign courts based on new order and tournament strategy
        let matchesWithCourts = CourtAssignmentManager.assignCourts(
            to: newMatches, 
            tournament: tournament
        )
        
        // Update local state immediately
        var updatedMatches = tournament.matches
        
        // Replace the matches for this group
        let groupId = newMatches.first?.groupId
        updatedMatches.removeAll { $0.groupId == groupId }
        updatedMatches.append(contentsOf: matchesWithCourts)
        
        self.tournament?.matches = updatedMatches
        
        // Save to Firestore
        do {
            try await tournamentRepository.updateMatches(tournamentId: tournamentId, matches: matchesWithCourts)
        } catch {
            // Reload from server on error
            await loadTournament()
            self.error = error
        }
    }
    
    /// Reassigns all courts based on current tournament strategy
    func reassignAllCourts() async {
        guard let tournament = tournament else { return }
        
        let reassignedMatches = CourtAssignmentManager.assignCourts(
            to: tournament.matches,
            tournament: tournament
        )
        
        // Update local state
        self.tournament?.matches = reassignedMatches
        
        // Save to repository
        do {
            try await tournamentRepository.updateMatches(tournamentId: tournamentId, matches: reassignedMatches)
        } catch {
            await loadTournament()
            self.error = error
        }
    }
    
    /// Updates the court assignment strategy and reassigns courts
    func updateCourtStrategy(_ strategy: CourtAssignmentStrategy) async {
        guard var tournament = tournament else { return }
        
        // Update strategy
        tournament.courtAssignmentStrategy = strategy
        
        // Reassign courts with new strategy
        let reassignedMatches = CourtAssignmentManager.assignCourts(
            to: tournament.matches,
            tournament: tournament
        )
        
        // Update local state
        tournament.matches = reassignedMatches
        self.tournament = tournament
        
        // Save to repository
        do {
            try await tournamentRepository.updateTournament(tournament)
            try await tournamentRepository.updateMatches(tournamentId: tournamentId, matches: reassignedMatches)
        } catch {
            await loadTournament()
            self.error = error
        }
    }
    
    func updateMatchScore(matchId: String, score1: Int, score2: Int) async {
        do {
            try await tournamentRepository.updateMatchScore(
                tournamentId: tournamentId, 
                matchId: matchId, 
                score1: score1, 
                score2: score2
            )
            
            // Update local state
            if let matchIndex = tournament?.matches.firstIndex(where: { $0.id == matchId }) {
                tournament?.matches[matchIndex].score1 = score1
                tournament?.matches[matchIndex].score2 = score2
            }
            
        } catch {
            self.error = error
        }
    }
    
    var groupedMatches: [String: [Match]] {
        guard let matches = tournament?.matches else { return [:] }
        
        return Dictionary(grouping: matches) { match in
            match.groupId ?? "Knockout"
        }
    }
}
