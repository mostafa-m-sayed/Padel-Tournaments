//
//  KnockoutStageViewModel.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation
import Combine

// If you don't have Firebase, you can comment out these Firebase-related lines
// import Firebase
// import FirebaseFirestore

@MainActor
final class KnockoutStageViewModel: ObservableObject {
    @Published var tournament: Tournament?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let tournamentId: String
    // Comment out if you don't have these protocols yet
    // private let tournamentRepository: TournamentRepositoryProtocol
    // private let progressionManager: TournamentProgressionManagerProtocol
    
    // Comment out if you don't have Firebase
    // private var tournamentListener: ListenerRegistration?
    // private var matchesListener: ListenerRegistration?
    
    init(tournamentId: String) {
        self.tournamentId = tournamentId
        // Comment out if you don't have these protocols yet
        // self.tournamentRepository = tournamentRepository
        // self.progressionManager = progressionManager
    }
    
    deinit {
        // Comment out if you don't have Firebase
        // tournamentListener?.remove()
        // matchesListener?.remove()
    }
    
    func startListening() {
        // Simplified version - you can implement Firebase listeners later
        isLoading = false
    }
    
    func stopListening() {
        // Simplified version - you can implement Firebase listeners later
    }
    
    func loadTournament() async {
        isLoading = true
        error = nil
        
        // Simplified version - you can implement actual loading later
        // For now, just use the initial tournament passed to the view
        
        isLoading = false
    }
    
    func updateMatchScore(matchId: String, score1: Int, score2: Int) async {
        guard var tournament = tournament else { return }
        
        // Update local tournament data
        if let matchIndex = tournament.matches.firstIndex(where: { $0.id == matchId }) {
            tournament.matches[matchIndex].score1 = score1
            tournament.matches[matchIndex].score2 = score2
            self.tournament = tournament
            
            // You can add Firebase persistence here later
            print("Updated match \(matchId) with score \(score1)-\(score2)")
        }
    }
    
    // MARK: - Private Methods (Simplified)
    
    // You can implement these later when you have Firebase and other dependencies
    /*
    private func setupTournamentListener() {
        // Firebase tournament listener implementation
    }
    
    private func setupMatchesListener() {
        // Firebase matches listener implementation  
    }
    
    private func checkAndUpdateBracketProgression() {
        // Tournament progression logic implementation
    }
    
    private func checkBracketProgression(for match: Match) async {
        // Match progression logic implementation
    }
    
    private func updateBracketWithSemifinalResults() async {
        // Bracket update logic implementation
    }
    */
}

// MARK: - Computed Properties

extension KnockoutStageViewModel {
    var knockoutMatches: [Match] {
        tournament?.matches.filter { $0.stage != .group } ?? []
    }
    
    var semifinalMatches: [Match] {
        knockoutMatches.filter { $0.stage == .semi }
    }
    
    var thirdPlaceMatch: Match? {
        knockoutMatches.first { $0.stage == .thirdPlace }
    }
    
    var finalMatch: Match? {
        knockoutMatches.first { $0.stage == .final }
    }
    
    var allSemifinalsComplete: Bool {
        let semis = semifinalMatches
        return !semis.isEmpty && semis.allSatisfy { $0.isPlayed }
    }
    
    var tournamentComplete: Bool {
        finalMatch?.isPlayed ?? false
    }
    
    var completedKnockoutMatches: Int {
        knockoutMatches.filter { $0.isPlayed }.count
    }
    
    var knockoutProgress: Double {
        guard !knockoutMatches.isEmpty else { return 0 }
        return Double(completedKnockoutMatches) / Double(knockoutMatches.count)
    }
    
    var hasUnplayedMatches: Bool {
        knockoutMatches.contains { !$0.isPlayed }
    }
    
    var semiMatches: [Match] {
        semifinalMatches
    }
    
    var finalMatches: [Match] {
        var matches: [Match] = []
        if let thirdPlace = thirdPlaceMatch {
            matches.append(thirdPlace)
        }
        if let final = finalMatch {
            matches.append(final)
        }
        return matches
    }
}