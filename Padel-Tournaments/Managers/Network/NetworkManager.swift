//
//  NetworkManager.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation
import Firebase
import FirebaseFirestore

protocol NetworkManagerProtocol {
    func fetchTournaments() async throws -> [Tournament]
    func createTournament(_ tournament: Tournament) async throws
    func updateTournament(_ tournament: Tournament) async throws
    func deleteTournament(id: String) async throws
    func joinTournament(tournamentId: String, team: Team) async throws
    
    // New methods for complete tournament management
    func createTournamentWithSubcollections(_ tournament: Tournament, teams: [Team], groups: [Group], matches: [Match]) async throws
    func fetchTournamentDetails(id: String) async throws -> Tournament
    func updateMatches(tournamentId: String, matches: [Match]) async throws
    func updateMatchScore(tournamentId: String, matchId: String, score1: Int, score2: Int) async throws
}

final class NetworkManager: NetworkManagerProtocol {
    private let db = Firestore.firestore()
    
    func fetchTournaments() async throws -> [Tournament] {
        do {
            let snapshot = try await db.collection("tournaments").getDocuments()
            return snapshot.documents.compactMap { document in
                try? document.data(as: Tournament.self)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    func createTournament(_ tournament: Tournament) async throws {
        do {
            try db.collection("tournaments").document(tournament.id).setData(from: tournament)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    func updateTournament(_ tournament: Tournament) async throws {
        do {
            try db.collection("tournaments").document(tournament.id).setData(from: tournament)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    func deleteTournament(id: String) async throws {
        do {
            try await db.collection("tournaments").document(id).delete()
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    func joinTournament(tournamentId: String, team: Team) async throws {
        do {
            try db.collection("tournaments").document(tournamentId)
                .collection("teams").document(team.id).setData(from: team)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    // MARK: - Complete Tournament Management
    
    func createTournamentWithSubcollections(_ tournament: Tournament, teams: [Team], groups: [Group], matches: [Match]) async throws {
        let batch = db.batch()
        
        // Create main tournament document
        let tournamentRef = db.collection("tournaments").document(tournament.id)
        do {
            try batch.setData(from: tournament, forDocument: tournamentRef)
        } catch {
            throw NetworkError.unknown(error)
        }
        
        // Add teams subcollection
        for team in teams {
            let teamRef = tournamentRef.collection("teams").document(team.id)
            do {
                try batch.setData(from: team, forDocument: teamRef)
            } catch {
                throw NetworkError.unknown(error)
            }
        }
        
        // Add groups subcollection
        for group in groups {
            let groupRef = tournamentRef.collection("groups").document(group.id)
            do {
                try batch.setData(from: group, forDocument: groupRef)
            } catch {
                throw NetworkError.unknown(error)
            }
        }
        
        // Add matches subcollection
        for match in matches {
            let matchRef = tournamentRef.collection("matches").document(match.id)
            do {
                try batch.setData(from: match, forDocument: matchRef)
            } catch {
                throw NetworkError.unknown(error)
            }
        }
        
        // Commit the batch
        do {
            try await batch.commit()
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    func fetchTournamentDetails(id: String) async throws -> Tournament {
        do {
            let tournamentDoc = try await db.collection("tournaments").document(id).getDocument()
            
            guard tournamentDoc.exists else {
                throw NetworkError.documentNotFound
            }
            
            var tournament = try tournamentDoc.data(as: Tournament.self)
            
            // Fetch teams
            let teamsSnapshot = try await db.collection("tournaments").document(id)
                .collection("teams").getDocuments()
            tournament.teams = teamsSnapshot.documents.compactMap { doc in
                try? doc.data(as: Team.self)
            }
            
            // Fetch groups
            let groupsSnapshot = try await db.collection("tournaments").document(id)
                .collection("groups").getDocuments()
            tournament.groups = groupsSnapshot.documents.compactMap { doc in
                try? doc.data(as: Group.self)
            }
            
            // Fetch matches
            let matchesSnapshot = try await db.collection("tournaments").document(id)
                .collection("matches").getDocuments()
            tournament.matches = matchesSnapshot.documents.compactMap { doc in
                try? doc.data(as: Match.self)
            }
            
            return tournament
            
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    func updateMatches(tournamentId: String, matches: [Match]) async throws {
        let batch = db.batch()
        
        for match in matches {
            let matchRef = db.collection("tournaments").document(tournamentId)
                .collection("matches").document(match.id)
            do {
                try batch.setData(from: match, forDocument: matchRef)
            } catch {
                throw NetworkError.unknown(error)
            }
        }
        
        do {
            try await batch.commit()
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    func updateMatchScore(tournamentId: String, matchId: String, score1: Int, score2: Int) async throws {
        do {
            try await db.collection("tournaments").document(tournamentId)
                .collection("matches").document(matchId)
                .updateData([
                    "score1": score1,
                    "score2": score2
                ])
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
