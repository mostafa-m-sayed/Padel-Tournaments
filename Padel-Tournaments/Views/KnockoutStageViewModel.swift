//
//  KnockoutStageViewModel.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation
import Combine
import Firebase
import FirebaseFirestore

@MainActor
final class KnockoutStageViewModel: ObservableObject {
    @Published var tournament: Tournament?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showTournamentResults = false
    @Published var tournamentWinner: Team?
    @Published var topThreeTeams: [Team] = []
    @Published var finalMatchScore: (team1Score: Int, team2Score: Int)?
    
    private let tournamentId: String
    private let tournamentRepository: TournamentRepositoryProtocol
    private let progressionManager: TournamentProgressionManagerProtocol
    private var tournamentListener: ListenerRegistration?
    private var matchesListener: ListenerRegistration?
    
    init(tournamentId: String,
         tournamentRepository: TournamentRepositoryProtocol = TournamentRepository(),
         progressionManager: TournamentProgressionManagerProtocol = TournamentProgressionManager()) {
        self.tournamentId = tournamentId
        self.tournamentRepository = tournamentRepository
        self.progressionManager = progressionManager
    }
    
    deinit {
        tournamentListener?.remove()
        matchesListener?.remove()
    }
    
    func startListening() {
        stopListening() // Clean up any existing listeners
        isLoading = true
        error = nil
        
        setupTournamentListener()
        setupMatchesListener()
    }
    
    func stopListening() {
        tournamentListener?.remove()
        matchesListener?.remove()
        tournamentListener = nil
        matchesListener = nil
    }
    
    func loadTournament() async {
        isLoading = true
        error = nil
        
        do {
            tournament = try await tournamentRepository.fetchTournamentDetails(id: tournamentId)
            checkAndUpdateBracketProgression()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func updateMatchScore(matchId: String, score1: Int, score2: Int) async {
        guard let tournament = tournament else { return }
        
        do {
            // Update match score in repository
            try await tournamentRepository.updateMatchScore(
                tournamentId: tournamentId,
                matchId: matchId,
                score1: score1,
                score2: score2
            )
            
            // Update local tournament data
            if let matchIndex = tournament.matches.firstIndex(where: { $0.id == matchId }) {
                var updatedTournament = tournament
                updatedTournament.matches[matchIndex].score1 = score1
                updatedTournament.matches[matchIndex].score2 = score2
                self.tournament = updatedTournament
                
                // Check if bracket progression is needed
                await checkBracketProgression(for: updatedTournament.matches[matchIndex])
            }
            
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Private Methods
    
    private func setupTournamentListener() {
        let db = Firestore.firestore()
        
        tournamentListener = db.collection("tournaments")
            .document(tournamentId)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.error = error
                        self.isLoading = false
                        return
                    }
                    
                    guard let document = snapshot, document.exists else {
                        self.error = NetworkError.documentNotFound
                        self.isLoading = false
                        return
                    }
                    
                    do {
                        let tournament = try document.data(as: Tournament.self)
                        self.tournament = tournament
                        self.checkAndUpdateBracketProgression()
                        self.isLoading = false
                    } catch {
                        self.error = error
                        self.isLoading = false
                    }
                }
            }
    }
    
    private func setupMatchesListener() {
        let db = Firestore.firestore()
        
        matchesListener = db.collection("tournaments")
            .document(tournamentId)
            .collection("matches")
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.error = error
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    do {
                        let matches = try documents.compactMap { try $0.data(as: Match.self) }
                        
                        if var tournament = self.tournament {
                            tournament.matches = matches
                            self.tournament = tournament
                            self.checkAndUpdateBracketProgression()
                        }
                    } catch {
                        self.error = error
                    }
                }
            }
    }
    
    private func checkAndUpdateBracketProgression() {
        guard let tournament = tournament else { return }
        
        // Check if semifinals are complete and we need to update bracket
        let semifinals = tournament.matches.filter { $0.stage == .semi }
        let completedSemis = semifinals.filter { $0.isPlayed }
        
        if semifinals.count == completedSemis.count && completedSemis.count >= 2 {
            Task {
                await updateBracketWithSemifinalResults()
            }
        }
        
        // Check if tournament is complete (final match finished)
        checkTournamentCompletion()
    }
    
    private func checkTournamentCompletion() {
        guard let tournament = tournament else { return }
        
        // Find the final match
        if let finalMatch = tournament.matches.first(where: { $0.stage == .final }),
           finalMatch.isPlayed {
            
            // Tournament is complete! Calculate final results
            calculateFinalResults(tournament: tournament, finalMatch: finalMatch)
            showTournamentResults = true
        }
    }
    
    private func calculateFinalResults(tournament: Tournament, finalMatch: Match) {
        // Store final match score
        finalMatchScore = (team1Score: finalMatch.score1 ?? 0, team2Score: finalMatch.score2 ?? 0)
        
        // Determine top 3 teams
        var results: [Team] = []
        
        // 1st Place - Winner of final
        let finalWinnerId = (finalMatch.score1 ?? 0) > (finalMatch.score2 ?? 0) ? finalMatch.team1Id : finalMatch.team2Id
        if let winner = tournament.teams.first(where: { $0.id == finalWinnerId }) {
            results.append(winner)
            tournamentWinner = winner
        }
        
        // 2nd Place - Loser of final
        let finalLoserId = (finalMatch.score1 ?? 0) > (finalMatch.score2 ?? 0) ? finalMatch.team2Id : finalMatch.team1Id
        if let runnerUp = tournament.teams.first(where: { $0.id == finalLoserId }) {
            results.append(runnerUp)
        }
        
        // 3rd Place - Winner of third place match (if exists)
        if let thirdPlaceMatch = tournament.matches.first(where: { $0.stage == .thirdPlace }),
           thirdPlaceMatch.isPlayed {
            let thirdPlaceWinnerId = (thirdPlaceMatch.score1 ?? 0) > (thirdPlaceMatch.score2 ?? 0) ? 
                                   thirdPlaceMatch.team1Id : thirdPlaceMatch.team2Id
            if let thirdPlace = tournament.teams.first(where: { $0.id == thirdPlaceWinnerId }) {
                results.append(thirdPlace)
            }
        }
        
        topThreeTeams = results
        print("🏆 Tournament Complete! Winner: \(tournamentWinner?.displayName ?? "Unknown")")
    }
    
    private func checkBracketProgression(for match: Match) async {
        guard let tournament = tournament else { return }
        
        // If this was a semifinal that just completed, update bracket
        if match.stage == .semi && match.isPlayed {
            await updateBracketWithSemifinalResults()
        }
    }
    
    private func updateBracketWithSemifinalResults() async {
        guard let tournament = tournament else { return }
        
        do {
            let updatedTournament = try await progressionManager.updateBracketMatches(tournament: tournament)
            self.tournament = updatedTournament
        } catch {
            self.error = error
        }
    }
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
