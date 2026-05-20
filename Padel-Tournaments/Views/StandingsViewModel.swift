//
//  StandingsViewModel.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation
import Combine
import Firebase
import FirebaseFirestore

@MainActor
final class StandingsViewModel: ObservableObject {
    @Published var standingsByGroup: [String: [StandingEntry]] = [:]
    @Published var tournament: Tournament?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let tournamentRepository: TournamentRepositoryProtocol
    private var matchesListener: ListenerRegistration?
    private var tournamentListener: ListenerRegistration?
    
    init(tournamentRepository: TournamentRepositoryProtocol = TournamentRepository()) {
        self.tournamentRepository = tournamentRepository
    }
    
    deinit {
        matchesListener?.remove()
        tournamentListener?.remove()
    }
    
    func startListening(tournamentId: String) {
        stopListening() // Clean up any existing listeners
        isLoading = true
        error = nil
        
        setupTournamentListener(tournamentId: tournamentId)
        setupMatchesListener(tournamentId: tournamentId)
    }
    
    func stopListening() {
        matchesListener?.remove()
        tournamentListener?.remove()
        matchesListener = nil
        tournamentListener = nil
    }
    
    private func setupTournamentListener(tournamentId: String) {
        let db = Firestore.firestore()
        
        tournamentListener = db.collection("tournaments")
            .document(tournamentId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                Task { @MainActor in
                    if let error = error {
                        self?.error = error
                        self?.isLoading = false
                        return
                    }
                    
                    guard let document = documentSnapshot,
                          document.exists,
                          let tournament = try? document.data(as: Tournament.self) else {
                        self?.error = NetworkError.documentNotFound
                        self?.isLoading = false
                        return
                    }
                    
                    await self?.loadTournamentDetails(tournament)
                }
            }
    }
    
    private func setupMatchesListener(tournamentId: String) {
        let db = Firestore.firestore()
        
        matchesListener = db.collection("tournaments")
            .document(tournamentId)
            .collection("matches")
            .addSnapshotListener { [weak self] querySnapshot, error in
                Task { @MainActor in
                    if let error = error {
                        self?.error = error
                        return
                    }
                    
                    guard let snapshot = querySnapshot else { return }
                    
                    let matches = snapshot.documents.compactMap { doc in
                        try? doc.data(as: Match.self)
                    }
                    
                    // Update matches in tournament and recompute standings
                    self?.tournament?.matches = matches
                    self?.computeStandings()
                }
            }
    }
    
    private func loadTournamentDetails(_ baseTournament: Tournament) async {
        do {
            let fullTournament = try await tournamentRepository.fetchTournamentDetails(id: baseTournament.id)
            self.tournament = fullTournament
            computeStandings()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    private func computeStandings() {
        guard let tournament = tournament else { return }
        
        var standingsByGroup: [String: [StandingEntry]] = [:]
        
        // Initialize standings for each group
        for group in tournament.groups {
            let groupTeams = group.teams(from: tournament.teams)
            var standings: [StandingEntry] = []
            
            for team in groupTeams {
                var entry = StandingEntry(id: team.id, team: team)
                
                // Find all matches for this team in this group
                let teamMatches = tournament.matches.filter { match in
                    match.groupId == group.id && 
                    (match.team1Id == team.id || match.team2Id == team.id) &&
                    match.isPlayed
                }
                
                // Calculate stats from matches
                for match in teamMatches {
                    let isTeam1 = match.team1Id == team.id
                    let teamScore = isTeam1 ? match.score1! : match.score2!
                    let opponentScore = isTeam1 ? match.score2! : match.score1!
                    
                    // Update match record
                    if teamScore > opponentScore {
                        entry.wins += 1
                    } else if teamScore < opponentScore {
                        entry.losses += 1
                    }
                    // Note: Draws shouldn't happen in padel, but we don't increment either
                    
                    // Update points (games) - this is what we use for tiebreaker
                    entry.pointsFor += teamScore
                    entry.pointsAgainst += opponentScore
                }
                
                standings.append(entry)
            }
            
            // Sort standings with proper tiebreaker rules
            standingsByGroup[group.id] = StandingEntry.sorted(standings)
        }
        
        self.standingsByGroup = standingsByGroup
    }
    
    // Helper computed properties
    var groupStandings: [(groupName: String, standings: [StandingEntry])] {
        let sortedGroups = standingsByGroup.keys.sorted()
        return sortedGroups.compactMap { groupId in
            guard let standings = standingsByGroup[groupId] else { return nil }
            return (groupName: groupId, standings: standings)
        }
    }
    
    var topTeamsPerGroup: [String: [StandingEntry]] {
        var topTeams: [String: [StandingEntry]] = [:]
        for (groupId, standings) in standingsByGroup {
            topTeams[groupId] = Array(standings.prefix(2)) // Top 2 per group
        }
        return topTeams
    }
    
    func refreshData(tournamentId: String) {
        startListening(tournamentId: tournamentId)
    }
}
