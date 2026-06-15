//
//  KnockoutViewModel.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation
import Combine
import Firebase
import FirebaseFirestore

@MainActor
final class KnockoutViewModel: ObservableObject {
    @Published var tournament: Tournament?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let tournamentRepository: TournamentRepositoryProtocol
    private let progressionManager: TournamentProgressionManagerProtocol
    private var tournamentListener: ListenerRegistration?
    private var matchesListener: ListenerRegistration?
    
    init(tournamentRepository: TournamentRepositoryProtocol = TournamentRepository(),
         progressionManager: TournamentProgressionManagerProtocol = TournamentProgressionManager()) {
        self.tournamentRepository = tournamentRepository
        self.progressionManager = progressionManager
    }
    
    deinit {
        tournamentListener?.remove()
        matchesListener?.remove()
    }
    
    // MARK: - Public Interface
    
    func startListening(tournamentId: String) {
        stopListening()
        isLoading = true
        error = nil
        
        setupTournamentListener(tournamentId: tournamentId)
        setupMatchesListener(tournamentId: tournamentId)
    }
    
    func stopListening() {
        tournamentListener?.remove()
        matchesListener?.remove()
    }
    
    func updateMatchScore(matchId: String, score1: Int, score2: Int) async {
        guard let tournament = tournament else { return }
        
        do {
            // Update match score
            try await tournamentRepository.updateMatchScore(
                tournamentId: tournament.id,
                matchId: matchId,
                score1: score1,
                score2: score2
            )
            
            // Check if we need to update bracket progression
            await checkAndUpdateBracketProgression()
            
        } catch {
            self.error = error
            print("❌ Failed to update knockout match score: \(error)")
        }
    }
    
    // MARK: - Computed Properties
    
    var knockoutMatches: [Match] {
        tournament?.matches.filter { $0.stage != .group } ?? []
    }
    
    var semiMatches: [Match] {
        knockoutMatches.filter { $0.stage == .semi }.sorted { $0.court < $1.court }
    }
    
    var thirdPlaceMatch: Match? {
        knockoutMatches.first { $0.stage == .thirdPlace }
    }
    
    var finalMatch: Match? {
        knockoutMatches.first { $0.stage == .final }
    }
    
    var finalMatches: [Match] {
        knockoutMatches.filter { $0.stage == .thirdPlace || $0.stage == .final }
    }
    
    var completedKnockoutMatches: Int {
        knockoutMatches.filter { $0.isPlayed }.count
    }
    
    var knockoutProgress: Double {
        guard !knockoutMatches.isEmpty else { return 0.0 }
        return Double(completedKnockoutMatches) / Double(knockoutMatches.count)
    }
    
    var hasUnplayedMatches: Bool {
        knockoutMatches.contains { !$0.isPlayed }
    }
    
    var isKnockoutComplete: Bool {
        knockoutMatches.allSatisfy { $0.isPlayed }
    }
    
    var tournamentWinner: Team? {
        guard let finalMatch = finalMatch,
              finalMatch.isPlayed,
              let winnerId = finalMatch.winnerId else { return nil }
        
        return tournament?.teams.first { $0.id == winnerId }
    }
    
    var tournamentRunnerUp: Team? {
        guard let finalMatch = finalMatch,
              finalMatch.isPlayed,
              let loserId = finalMatch.loserId else { return nil }
        
        return tournament?.teams.first { $0.id == loserId }
    }
    
    var thirdPlaceTeam: Team? {
        guard let thirdPlaceMatch = thirdPlaceMatch,
              thirdPlaceMatch.isPlayed,
              let winnerId = thirdPlaceMatch.winnerId else { return nil }
        
        return tournament?.teams.first { $0.id == winnerId }
    }
    
    // MARK: - Private Methods
    
    private func setupTournamentListener(tournamentId: String) {
        tournamentListener = Firestore.firestore()
            .collection("tournaments")
            .document(tournamentId)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.error = error
                        self.isLoading = false
                        return
                    }
                    
                    guard let document = snapshot,
                          let tournament = try? document.data(as: Tournament.self) else {
                        self.error = NetworkError.invalidResponse
                        self.isLoading = false
                        return
                    }
                    
                    self.tournament = tournament
                    self.isLoading = false
                }
            }
    }
    
    private func setupMatchesListener(tournamentId: String) {
        matchesListener = Firestore.firestore()
            .collection("tournaments")
            .document(tournamentId)
            .collection("matches")
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("❌ Matches listener error: \(error)")
                        return
                    }
                    
                    guard let snapshot = snapshot else { return }
                    
                    let matches = snapshot.documents.compactMap { document in
                        try? document.data(as: Match.self)
                    }
                    
                    // Update tournament with new matches
                    if var currentTournament = self.tournament {
                        currentTournament.matches = matches
                        self.tournament = currentTournament
                    }
                }
            }
    }
    
    private func checkAndUpdateBracketProgression() async {
        guard let tournament = tournament else { return }
        
        do {
            // Check if semifinals are complete and we need to populate finals
            let semiMatches = tournament.matches.filter { $0.stage == .semi && $0.isPlayed }
            
            if semiMatches.count == 2 {
                // Both semifinals complete - update third place and final matches
                let updatedTournament = try await progressionManager.updateBracketMatches(tournament: tournament)
                
                // The listener will pick up the changes, but we can update locally for immediate UI response
                self.tournament = updatedTournament
                
                print("🏆 Updated bracket matches after semifinals completion")
            }
            
        } catch {
            self.error = error
            print("❌ Failed to update bracket progression: \(error)")
        }
    }
    
    func refreshData(tournamentId: String) async {
        isLoading = true
        error = nil
        
        do {
            let updatedTournament = try await tournamentRepository.fetchTournamentDetails(id: tournamentId)
            tournament = updatedTournament
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}