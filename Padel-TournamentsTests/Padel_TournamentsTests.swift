////
////  Padel_TournamentsTests.swift
////  Padel-TournamentsTests
////
////  Created by Mostafa Sayed on 12/05/2026.
////
//
//import Testing
//import Foundation
//@testable import Padel_Tournaments
//
//// MARK: - Mock Repository
//@MainActor
//class MockTournamentRepository: TournamentRepositoryProtocol {
//    func createTournament(_ tournament: Padel_Tournaments.Tournament) async throws {
//        <#code#>
//    }
//    
//    func joinTournament(tournamentId: String, team: Padel_Tournaments.Team) async throws {
//        <#code#>
//    }
//    
//    var tournaments: [Tournament] = []
//    var shouldThrowError = false
//    var errorToThrow: Error = MockError.testError
//    var updateMatchScoreCallCount = 0
//    var updateTournamentCallCount = 0
//    var updateMatchesCallCount = 0
//    
//    func getAllTournaments() async throws -> [Tournament] {
//        if shouldThrowError {
//            throw errorToThrow
//        }
//        return tournaments
//    }
//    
//    func fetchTournamentDetails(id: String) async throws -> Tournament {
//        if shouldThrowError {
//            throw errorToThrow
//        }
//        return tournaments.first { $0.id == id } ?? createMockTournament(id: id)
//    }
//    
//    func createTournamentWithSubcollections(_ tournament: Tournament, teams: [Team], groups: [TournamentGroup], matches: [Match]) async throws {
//        if shouldThrowError {
//            throw errorToThrow
//        }
//        tournaments.append(tournament)
//    }
//    
//    func updateTournament(_ tournament: Tournament) async throws {
//        updateTournamentCallCount += 1
//        if shouldThrowError {
//            throw errorToThrow
//        }
//        if let index = tournaments.firstIndex(where: { $0.id == tournament.id }) {
//            tournaments[index] = tournament
//        }
//    }
//    
//    func deleteTournament(id: String) async throws {
//        if shouldThrowError {
//            throw errorToThrow
//        }
//        tournaments.removeAll { $0.id == id }
//    }
//    
//    func updateMatchScore(tournamentId: String, matchId: String, score1: Int?, score2: Int?) async throws {
//        updateMatchScoreCallCount += 1
//        if shouldThrowError {
//            throw errorToThrow
//        }
//    }
//    
//    func updateMatches(tournamentId: String, matches: [Match]) async throws {
//        updateMatchesCallCount += 1
//        if shouldThrowError {
//            throw errorToThrow
//        }
//    }
//    
//    func listenToTournament(tournamentId: String, completion: @escaping (Tournament?) -> Void) -> ListenerRegistration? {
//        return nil
//    }
//    
//    func listenToMatches(tournamentId: String, completion: @escaping ([Match]) -> Void) -> ListenerRegistration? {
//        return nil
//    }
//    
//    private func createMockTournament(id: String) -> Tournament {
//        return Tournament(
//            id: id,
//            name: "Test Tournament",
//            courts: 2,
//            numberOfGroups: 2,
//            setType: .short,
//            status: .groupStage,
//            createdAt: Date(),
//            courtAssignmentStrategy: .automatic,
//            teams: createMockTeams(),
//            groups: createMockGroups(),
//            matches: createMockMatches()
//        )
//    }
//    
//    private func createMockTeams() -> [Team] {
//        return [
//            Team(id: "team1", name: "Team 1", player1: Player(id: "p1", name: "Player 1"), player2: Player(id: "p2", name: "Player 2")),
//            Team(id: "team2", name: "Team 2", player1: Player(id: "p3", name: "Player 3"), player2: Player(id: "p4", name: "Player 4")),
//            Team(id: "team3", name: "Team 3", player1: Player(id: "p5", name: "Player 5"), player2: Player(id: "p6", name: "Player 6")),
//            Team(id: "team4", name: "Team 4", player1: Player(id: "p7", name: "Player 7"), player2: Player(id: "p8", name: "Player 8"))
//        ]
//    }
//    
//    private func createMockGroups() -> [TournamentGroup] {
//        return [
//            TournamentGroup(id: "A", name: "A", teamIds: ["team1", "team2"]),
//            TournamentGroup(id: "B", name: "B", teamIds: ["team3", "team4"])
//        ]
//    }
//    
//    private func createMockMatches() -> [Match] {
//        return [
//            Match(id: "match1", team1Id: "team1", team2Id: "team2", round: 1, court: 1, groupId: "A", score1: nil, score2: nil),
//            Match(id: "match2", team1Id: "team3", team2Id: "team4", round: 1, court: 2, groupId: "B", score1: nil, score2: nil)
//        ]
//    }
//}
//
//enum MockError: Error {
//    case testError
//}
//
//// MARK: - ScheduleViewModel Tests
//@Suite("ScheduleViewModel Tests")
//struct ScheduleViewModelTests {
//    
//    @Test("Initial state is correct")
//    func testInitialState() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = ScheduleViewModel(tournamentId: "test-id", tournamentRepository: mockRepo)
//        
//        #expect(viewModel.tournament == nil)
//        #expect(viewModel.isLoading == false)
//        #expect(viewModel.error == nil)
//        #expect(viewModel.showTableView == false)
//    }
//    
//    @Test("Load tournament successfully")
//    func testLoadTournamentSuccess() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = ScheduleViewModel(tournamentId: "test-id", tournamentRepository: mockRepo)
//        
//        await viewModel.loadTournament()
//        
//        #expect(viewModel.tournament != nil)
//        #expect(viewModel.isLoading == false)
//        #expect(viewModel.error == nil)
//        #expect(viewModel.tournament?.name == "Test Tournament")
//    }
//    
//    @Test("Load tournament with error")
//    func testLoadTournamentError() async {
//        let mockRepo = MockTournamentRepository()
//        mockRepo.shouldThrowError = true
//        let viewModel = ScheduleViewModel(tournamentId: "test-id", tournamentRepository: mockRepo)
//        
//        await viewModel.loadTournament()
//        
//        #expect(viewModel.tournament == nil)
//        #expect(viewModel.isLoading == false)
//        #expect(viewModel.error != nil)
//    }
//    
//    @Test("Update match score successfully")
//    func testUpdateMatchScore() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = ScheduleViewModel(tournamentId: "test-id", tournamentRepository: mockRepo)
//        
//        await viewModel.loadTournament()
//        await viewModel.updateMatchScore(matchId: "match1", score1: 6, score2: 4)
//        
//        #expect(mockRepo.updateMatchScoreCallCount == 1)
//        #expect(viewModel.error == nil)
//    }
//    
//    @Test("Update match score with error")
//    func testUpdateMatchScoreError() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = ScheduleViewModel(tournamentId: "test-id", tournamentRepository: mockRepo)
//        
//        await viewModel.loadTournament()
//        mockRepo.shouldThrowError = true
//        await viewModel.updateMatchScore(matchId: "match1", score1: 6, score2: 4)
//        
//        #expect(viewModel.error != nil)
//    }
//    
//    @Test("Reassign all courts")
//    func testReassignAllCourts() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = ScheduleViewModel(tournamentId: "test-id", tournamentRepository: mockRepo)
//        
//        await viewModel.loadTournament()
//        await viewModel.reassignAllCourts()
//        
//        #expect(mockRepo.updateMatchesCallCount == 1)
//    }
//    
//    @Test("Grouped matches returns correct grouping")
//    func testGroupedMatches() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = ScheduleViewModel(tournamentId: "test-id", tournamentRepository: mockRepo)
//        
//        await viewModel.loadTournament()
//        let groupedMatches = viewModel.groupedMatches
//        
//        #expect(groupedMatches.keys.count == 2)
//        #expect(groupedMatches["A"]?.count == 1)
//        #expect(groupedMatches["B"]?.count == 1)
//    }
//}
//
//// MARK: - CreateTournamentViewModel Tests
//@Suite("CreateTournamentViewModel Tests")
//struct CreateTournamentViewModelTests {
//    
//    @Test("Initial state is correct")
//    func testInitialState() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = CreateTournamentViewModel(tournamentRepository: mockRepo)
//        
//        #expect(viewModel.currentStep == .basicInfo)
//        #expect(viewModel.tournamentName == "")
//        #expect(viewModel.numberOfCourts == 1)
//        #expect(viewModel.numberOfGroups == 2)
//        #expect(viewModel.teams.isEmpty)
//        #expect(viewModel.groupA.isEmpty)
//        #expect(viewModel.groupB.isEmpty)
//        #expect(viewModel.isLoading == false)
//        #expect(viewModel.error == nil)
//    }
//    
//    @Test("Navigation through steps works correctly")
//    func testStepNavigation() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = CreateTournamentViewModel(tournamentRepository: mockRepo)
//        
//        // Initial step
//        #expect(viewModel.currentStep == .basicInfo)
//        
//        // Go to team setup
//        viewModel.nextStep()
//        #expect(viewModel.currentStep == .teamSetup)
//        
//        // Go back to basic info
//        viewModel.previousStep()
//        #expect(viewModel.currentStep == .basicInfo)
//    }
//    
//    @Test("Add team functionality")
//    func testAddTeam() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = CreateTournamentViewModel(tournamentRepository: mockRepo)
//        
//        viewModel.addTeam(player1Name: "Player 1", player2Name: "Player 2")
//        
//        #expect(viewModel.teams.count == 1)
//        #expect(viewModel.teams.first?.name == "Player 1 & Player 2")
//        #expect(viewModel.teams.first?.player1.name == "Player 1")
//        #expect(viewModel.teams.first?.player2.name == "Player 2")
//    }
//    
//    @Test("Remove team functionality")
//    func testRemoveTeam() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = CreateTournamentViewModel(tournamentRepository: mockRepo)
//        
//        // Add teams
//        viewModel.addTeam(player1Name: "Player 1", player2Name: "Player 2")
//        viewModel.addTeam(player1Name: "Player 3", player2Name: "Player 4")
//        
//        #expect(viewModel.teams.count == 2)
//        
//        // Remove one team
//        viewModel.removeTeam(at: 0)
//        
//        #expect(viewModel.teams.count == 1)
//        #expect(viewModel.teams.first?.name == "Player 3 & Player 4")
//    }
//    
//    @Test("Assign teams to groups")
//    func testAssignTeamToGroup() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = CreateTournamentViewModel(tournamentRepository: mockRepo)
//        
//        viewModel.addTeam(player1Name: "Player 1", player2Name: "Player 2")
//        viewModel.addTeam(player1Name: "Player 3", player2Name: "Player 4")
//        
//        let team1 = viewModel.teams[0]
//        let team2 = viewModel.teams[1]
//        
//        viewModel.assignTeamToGroup(team1, group: .groupA)
//        viewModel.assignTeamToGroup(team2, group: .groupB)
//        
//        #expect(viewModel.groupA.count == 1)
//        #expect(viewModel.groupB.count == 1)
//        #expect(viewModel.groupA.first?.id == team1.id)
//        #expect(viewModel.groupB.first?.id == team2.id)
//    }
//    
//    @Test("Randomize groups functionality")
//    func testRandomizeGroups() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = CreateTournamentViewModel(tournamentRepository: mockRepo)
//        
//        // Add 4 teams
//        for i in 1...4 {
//            viewModel.addTeam(player1Name: "Player \(i*2-1)", player2Name: "Player \(i*2)")
//        }
//        
//        viewModel.randomizeGroups()
//        
//        #expect(viewModel.groupA.count == 2)
//        #expect(viewModel.groupB.count == 2)
//        #expect(viewModel.unassignedTeams.isEmpty)
//    }
//    
//    @Test("Can proceed validations")
//    func testCanProceedValidations() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = CreateTournamentViewModel(tournamentRepository: mockRepo)
//        
//        // Initially can't proceed from basic info
//        #expect(viewModel.canProceedFromBasicInfo == false)
//        
//        // Set tournament name
//        viewModel.tournamentName = "Test Tournament"
//        #expect(viewModel.canProceedFromBasicInfo == true)
//        
//        // Initially can't proceed from team setup
//        #expect(viewModel.canProceedFromTeamSetup == false)
//        
//        // Add 4 teams
//        for i in 1...4 {
//            viewModel.addTeam(player1Name: "Player \(i*2-1)", player2Name: "Player \(i*2)")
//        }
//        #expect(viewModel.canProceedFromTeamSetup == true)
//        
//        // Initially can't create tournament
//        #expect(viewModel.canCreateTournament == false)
//        
//        // Assign teams to groups
//        viewModel.randomizeGroups()
//        #expect(viewModel.canCreateTournament == true)
//    }
//    
//    @Test("Create tournament successfully")
//    func testCreateTournamentSuccess() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = CreateTournamentViewModel(tournamentRepository: mockRepo)
//        
//        viewModel.tournamentName = "Test Tournament"
//        
//        // Add 4 teams and assign to groups
//        for i in 1...4 {
//            viewModel.addTeam(player1Name: "Player \(i*2-1)", player2Name: "Player \(i*2)")
//        }
//        viewModel.randomizeGroups()
//        
//        await viewModel.createTournament()
//        
//        #expect(viewModel.isLoading == false)
//        #expect(viewModel.error == nil)
//        #expect(viewModel.createdTournamentId != nil)
//        #expect(mockRepo.tournaments.count == 1)
//    }
//    
//    @Test("Create tournament with error")
//    func testCreateTournamentError() async {
//        let mockRepo = MockTournamentRepository()
//        mockRepo.shouldThrowError = true
//        let viewModel = CreateTournamentViewModel(tournamentRepository: mockRepo)
//        
//        viewModel.tournamentName = "Test Tournament"
//        
//        // Add 4 teams and assign to groups
//        for i in 1...4 {
//            viewModel.addTeam(player1Name: "Player \(i*2-1)", player2Name: "Player \(i*2)")
//        }
//        viewModel.randomizeGroups()
//        
//        await viewModel.createTournament()
//        
//        #expect(viewModel.isLoading == false)
//        #expect(viewModel.error != nil)
//        #expect(viewModel.createdTournamentId == nil)
//    }
//}
//
//// MARK: - TournamentListViewModel Tests
//@Suite("TournamentListViewModel Tests")
//struct TournamentListViewModelTests {
//    
//    @Test("Initial state is correct")
//    func testInitialState() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = TournamentListViewModel(tournamentRepository: mockRepo)
//        
//        #expect(viewModel.tournaments.isEmpty)
//        #expect(viewModel.isLoading == false)
//        #expect(viewModel.error == nil)
//    }
//    
//    @Test("Load tournaments successfully")
//    func testLoadTournamentsSuccess() async {
//        let mockRepo = MockTournamentRepository()
//        // Add some mock tournaments
//        let tournament1 = Tournament(id: "1", name: "Tournament 1", courts: 2, numberOfGroups: 2, setType: .short, status: .groupStage, createdAt: Date(), courtAssignmentStrategy: .automatic)
//        let tournament2 = Tournament(id: "2", name: "Tournament 2", courts: 3, numberOfGroups: 2, setType: .long, status: .completed, createdAt: Date(), courtAssignmentStrategy: .manual)
//        mockRepo.tournaments = [tournament1, tournament2]
//        
//        let viewModel = TournamentListViewModel(tournamentRepository: mockRepo)
//        
//        await viewModel.loadTournaments()
//        
//        #expect(viewModel.tournaments.count == 2)
//        #expect(viewModel.isLoading == false)
//        #expect(viewModel.error == nil)
//        #expect(viewModel.tournaments.first?.name == "Tournament 1")
//    }
//    
//    @Test("Load tournaments with error")
//    func testLoadTournamentsError() async {
//        let mockRepo = MockTournamentRepository()
//        mockRepo.shouldThrowError = true
//        let viewModel = TournamentListViewModel(tournamentRepository: mockRepo)
//        
//        await viewModel.loadTournaments()
//        
//        #expect(viewModel.tournaments.isEmpty)
//        #expect(viewModel.isLoading == false)
//        #expect(viewModel.error != nil)
//    }
//    
//    @Test("Delete tournament successfully")
//    func testDeleteTournamentSuccess() async {
//        let mockRepo = MockTournamentRepository()
//        let tournament1 = Tournament(id: "1", name: "Tournament 1", courts: 2, numberOfGroups: 2, setType: .short, status: .groupStage, createdAt: Date(), courtAssignmentStrategy: .automatic)
//        let tournament2 = Tournament(id: "2", name: "Tournament 2", courts: 3, numberOfGroups: 2, setType: .long, status: .completed, createdAt: Date(), courtAssignmentStrategy: .manual)
//        mockRepo.tournaments = [tournament1, tournament2]
//        
//        let viewModel = TournamentListViewModel(tournamentRepository: mockRepo)
//        await viewModel.loadTournaments()
//        
//        #expect(viewModel.tournaments.count == 2)
//        
//        await viewModel.deleteTournament(at: IndexSet([0]))
//        
//        #expect(viewModel.tournaments.count == 1)
//        #expect(viewModel.tournaments.first?.name == "Tournament 2")
//    }
//    
//    @Test("Delete tournament with error")
//    func testDeleteTournamentError() async {
//        let mockRepo = MockTournamentRepository()
//        let tournament1 = Tournament(id: "1", name: "Tournament 1", courts: 2, numberOfGroups: 2, setType: .short, status: .groupStage, createdAt: Date(), courtAssignmentStrategy: .automatic)
//        mockRepo.tournaments = [tournament1]
//        
//        let viewModel = TournamentListViewModel(tournamentRepository: mockRepo)
//        await viewModel.loadTournaments()
//        
//        mockRepo.shouldThrowError = true
//        await viewModel.deleteTournament(at: IndexSet([0]))
//        
//        #expect(viewModel.error != nil)
//    }
//    
//    @Test("Refresh tournaments")
//    func testRefreshTournaments() async {
//        let mockRepo = MockTournamentRepository()
//        let viewModel = TournamentListViewModel(tournamentRepository: mockRepo)
//        
//        // Initially no tournaments
//        await viewModel.loadTournaments()
//        #expect(viewModel.tournaments.isEmpty)
//        
//        // Add tournament to mock repo
//        let tournament = Tournament(id: "1", name: "New Tournament", courts: 2, numberOfGroups: 2, setType: .short, status: .groupStage, createdAt: Date(), courtAssignmentStrategy: .automatic)
//        mockRepo.tournaments = [tournament]
//        
//        // Refresh should load the new tournament
//        await viewModel.refreshTournaments()
//        #expect(viewModel.tournaments.count == 1)
//        #expect(viewModel.tournaments.first?.name == "New Tournament")
//    }
//    
//    @Test("Clear error functionality")
//    func testClearError() async {
//        let mockRepo = MockTournamentRepository()
//        mockRepo.shouldThrowError = true
//        let viewModel = TournamentListViewModel(tournamentRepository: mockRepo)
//        
//        await viewModel.loadTournaments()
//        #expect(viewModel.error != nil)
//        
//        viewModel.clearError()
//        #expect(viewModel.error == nil)
//    }
//}
