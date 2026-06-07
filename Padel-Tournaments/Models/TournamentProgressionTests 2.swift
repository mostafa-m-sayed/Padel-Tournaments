//
//  TournamentProgressionTests.swift
//  Padel-TournamentsTests
//
//  Created by Mostafa Sayed on 12/05/2026.
//
//
//import Testing
//import Firebase
//@testable import Padel_Tournaments
//
//@Suite("Tournament Progression Tests")
//struct TournamentProgressionTests {
//    
//    @Test("Detects group stage completion correctly")
//    func detectGroupStageCompletion() async throws {
//        // Given: A tournament with all group matches played
//        let tournament = createTestTournamentWithCompletedGroupStage()
//        let progressionManager = TournamentProgressionManager(
//            tournamentRepository: MockTournamentRepository()
//        )
//        
//        // When: Checking if group stage is complete
//        let isComplete = progressionManager.isGroupStageComplete(tournament: tournament)
//        
//        // Then: Should detect completion
//        #expect(isComplete == true, "Group stage should be detected as complete")
//    }
//    
//    @Test("Detects when can advance to knockout")
//    func detectCanAdvanceToKnockout() async throws {
//        // Given: A tournament with completed group stage and enough teams
//        let tournament = createTestTournamentWithCompletedGroupStage()
//        let progressionManager = TournamentProgressionManager(
//            tournamentRepository: MockTournamentRepository()
//        )
//        
//        // When: Checking if can advance to knockout
//        let canAdvance = progressionManager.canAdvanceToKnockout(tournament: tournament)
//        
//        // Then: Should allow advancement
//        #expect(canAdvance == true, "Should be able to advance to knockout stage")
//    }
//    
//    @Test("Generates correct knockout matches")
//    func generateKnockoutMatches() async throws {
//        // Given: A tournament and top teams per group
//        let tournament = createTestTournament()
//        let topTeamsPerGroup = createTestTopTeamsPerGroup()
//        let progressionManager = TournamentProgressionManager(
//            tournamentRepository: MockTournamentRepository()
//        )
//        
//        // When: Generating knockout matches
//        let knockoutMatches = progressionManager.generateKnockoutMatches(
//            from: tournament,
//            topTeamsPerGroup: topTeamsPerGroup
//        )
//        
//        // Then: Should create 4 matches (2 semis + 1 third place + 1 final)
//        #expect(knockoutMatches.count == 4, "Should create 4 knockout matches")
//        
//        let semiMatches = knockoutMatches.filter { $0.stage == .semi }
//        let thirdPlaceMatches = knockoutMatches.filter { $0.stage == .thirdPlace }
//        let finalMatches = knockoutMatches.filter { $0.stage == .final }
//        
//        #expect(semiMatches.count == 2, "Should create 2 semifinal matches")
//        #expect(thirdPlaceMatches.count == 1, "Should create 1 third place match")
//        #expect(finalMatches.count == 1, "Should create 1 final match")
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func createTestTournament() -> Tournament {
//        return Tournament(
//            id: "test-tournament",
//            name: "Test Tournament",
//            courts: 2,
//            numberOfGroups: 2,
//            setType: .short,
//            status: .groupStage,
//            createdAt: Date(),
//            courtAssignmentStrategy: .automatic,
//            teams: createTestTeams(),
//            groups: createTestGroups(),
//            matches: []
//        )
//    }
//    
//    private func createTestTournamentWithCompletedGroupStage() -> Tournament {
//        var tournament = createTestTournament()
//        tournament.matches = createTestCompletedGroupMatches()
//        return tournament
//    }
//    
//    private func createTestTeams() -> [Team] {
//        return [
//            Team(id: "team1", name: "Team 1", player1: Player(id: "p1", name: "Player 1"), player2: Player(id: "p2", name: "Player 2")),
//            Team(id: "team2", name: "Team 2", player1: Player(id: "p3", name: "Player 3"), player2: Player(id: "p4", name: "Player 4")),
//            Team(id: "team3", name: "Team 3", player1: Player(id: "p5", name: "Player 5"), player2: Player(id: "p6", name: "Player 6")),
//            Team(id: "team4", name: "Team 4", player1: Player(id: "p7", name: "Player 7"), player2: Player(id: "p8", name: "Player 8"))
//        ]
//    }
//    
//    private func createTestGroups() -> [TournamentGroup] {
//        return [
//            TournamentGroup(id: "A", name: "A", teamIds: ["team1", "team2"]),
//            TournamentGroup(id: "B", name: "B", teamIds: ["team3", "team4"])
//        ]
//    }
//    
//    private func createTestCompletedGroupMatches() -> [Match] {
//        return [
//            Match(id: "match1", court: 1, round: 1, stage: .group, team1Id: "team1", team2Id: "team2", score1: 4, score2: 2, groupId: "A"),
//            Match(id: "match2", court: 2, round: 1, stage: .group, team1Id: "team3", team2Id: "team4", score1: 4, score2: 1, groupId: "B")
//        ]
//    }
//    
//    private func createTestTopTeamsPerGroup() -> [String: [StandingEntry]] {
//        let teams = createTestTeams()
//        return [
//            "A": [
//                StandingEntry(id: "team1", team: teams[0], wins: 1, losses: 0, pointsFor: 4, pointsAgainst: 2),
//                StandingEntry(id: "team2", team: teams[1], wins: 0, losses: 1, pointsFor: 2, pointsAgainst: 4)
//            ],
//            "B": [
//                StandingEntry(id: "team3", team: teams[2], wins: 1, losses: 0, pointsFor: 4, pointsAgainst: 1),
//                StandingEntry(id: "team4", team: teams[3], wins: 0, losses: 1, pointsFor: 1, pointsAgainst: 4)
//            ]
//        ]
//    }
//}
//
//// MARK: - Mock Repository
//
//class MockTournamentRepository: TournamentRepositoryProtocol {
//    func getAllTournaments() async throws -> [Tournament] { return [] }
//    func createTournament(_ tournament: Tournament) async throws { }
//    func createTournamentWithSubcollections(_ tournament: Tournament, teams: [Team], groups: [TournamentGroup], matches: [Match]) async throws { }
//    func updateTournament(_ tournament: Tournament) async throws { }
//    func deleteTournament(id: String) async throws { }
//    func joinTournament(tournamentId: String, team: Team) async throws { }
//    func fetchTournamentDetails(id: String) async throws -> Tournament { 
//        return Tournament(
//            id: "test",
//            name: "Test",
//            courts: 1,
//            numberOfGroups: 2,
//            setType: .short,
//            status: .draft,
//            createdAt: Date(),
//            courtAssignmentStrategy: .automatic
//        )
//    }
//    func updateMatches(tournamentId: String, matches: [Match]) async throws { }
//    func updateMatchScore(tournamentId: String, matchId: String, score1: Int?, score2: Int?) async throws { }
//    func listenToMatches(tournamentId: String, completion: @escaping ([Match]) -> Void) -> ListenerRegistration { 
//        return MockListenerRegistration() 
//    }
//    func listenToTournament(tournamentId: String, completion: @escaping (Tournament?) -> Void) -> ListenerRegistration { 
//        return MockListenerRegistration() 
//    }
//}
//
//class MockListenerRegistration: ListenerRegistration {
//    func remove() { }
//}
