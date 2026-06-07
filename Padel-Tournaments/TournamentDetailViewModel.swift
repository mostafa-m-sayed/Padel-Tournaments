//
//  TournamentDetailViewModel.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation
import Combine
import Firebase
import FirebaseFirestore

@MainActor
final class TournamentDetailViewModel: ObservableObject {
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
        // Safe cleanup - Firebase listeners can be removed from any thread
        matchesListener?.remove()
        tournamentListener?.remove()
    }
    
    func startListening(tournamentId: String) {
        print("🔄 TournamentDetailViewModel: Starting to listen for tournament \(tournamentId)")
        stopListening() // Clean up any existing listeners
        
        setupTournamentListener(tournamentId: tournamentId)
        setupMatchesListener(tournamentId: tournamentId)
    }
    
    func stopListening() {
        print("🛑 TournamentDetailViewModel: Stopping listeners")
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
                        print("❌ Tournament listener error: \(error)")
                        self?.error = error
                        return
                    }
                    
                    guard let document = documentSnapshot,
                          document.exists,
                          let tournament = try? document.data(as: Tournament.self) else {
                        print("❌ Tournament document not found or failed to decode")
                        self?.error = NetworkError.documentNotFound
                        return
                    }
                    
                    print("🔄 Tournament updated: \(tournament.name)")
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
                        print("❌ Matches listener error: \(error)")
                        self?.error = error
                        return
                    }
                    
                    guard let snapshot = querySnapshot else { return }
                    
                    let matches = snapshot.documents.compactMap { doc in
                        try? doc.data(as: Match.self)
                    }
                    
                    print("🔄 Matches updated: \(matches.count) matches")
                    
                    // Update matches in tournament
                    self?.tournament?.matches = matches
                }
            }
    }
    
    private func loadTournamentDetails(_ baseTournament: Tournament) async {
        do {
            let fullTournament = try await tournamentRepository.fetchTournamentDetails(id: baseTournament.id)
            print("✅ Loaded full tournament: \(fullTournament.teams.count) teams, \(fullTournament.groups.count) groups, \(fullTournament.matches.count) matches")
            self.tournament = fullTournament
        } catch {
            print("❌ Failed to load tournament details: \(error)")
            self.error = error
        }
    }
}