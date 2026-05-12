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
}