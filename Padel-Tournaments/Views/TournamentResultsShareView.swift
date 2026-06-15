//
//  TournamentResultsShareView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 15/06/2026.
//

import SwiftUI

struct TournamentResultsShareView: View {
    let tournament: Tournament
    let topTeams: [Team] // Top 3 teams in order
    let finalScore: (team1Score: Int, team2Score: Int)?
    @Environment(\.dismiss) private var dismiss
    @State private var shareImage: UIImage?
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Main tournament results card
                    tournamentResultsCard
                        .background(
                            // Capture this view as an image for sharing
                            ViewThatFits {
                                shareableResultsView
                                    .background(.white) // Ensure white background for export
                                    .onAppear {
                                        captureResultsAsImage()
                                    }
                            }
                        )
                    
                    // Share button
                    shareButton
                    
                    // Additional stats
                    tournamentStatsView
                }
                .padding()
            }
            .navigationTitle("Tournament Results")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let shareImage = shareImage {
                ShareSheet(activityItems: [
                    shareImage,
                    createShareText()
                ])
            }
        }
    }
    
    // MARK: - Main Results Card
    
    @ViewBuilder
    private var tournamentResultsCard: some View {
        VStack(spacing: 24) {
            // Tournament header
            VStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                    .shadow(color: .orange, radius: 4, x: 0, y: 2)
                
                Text(tournament.name.uppercased())
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text("FINAL RESULTS")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .tracking(2)
            }
            
            // Podium layout
            podiumView
            
            // Tournament details
            VStack(spacing: 8) {
                HStack {
                    Label(DateFormatter.celebrationDate.string(from: tournament.createdAt), 
                          systemImage: "calendar")
                    
                    Spacer()
                    
                    Label("\(tournament.teams.count) Teams", 
                          systemImage: "person.2.fill")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if let finalScore = finalScore {
                    Text("Final Score: \(finalScore.team1Score)-\(finalScore.team2Score)")
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Podium View
    
    @ViewBuilder
    private var podiumView: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Second place (left)
            if topTeams.count > 1 {
                podiumPosition(
                    team: topTeams[1],
                    position: 2,
                    height: 80,
                    color: .gray,
                    medal: "🥈"
                )
            }
            
            // First place (center, tallest)
            if topTeams.count > 0 {
                podiumPosition(
                    team: topTeams[0],
                    position: 1,
                    height: 120,
                    color: .yellow,
                    medal: "🥇"
                )
            }
            
            // Third place (right)
            if topTeams.count > 2 {
                podiumPosition(
                    team: topTeams[2],
                    position: 3,
                    height: 60,
                    color: .orange,
                    medal: "🥉"
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func podiumPosition(team: Team, position: Int, height: CGFloat, color: Color, medal: String) -> some View {
        VStack(spacing: 8) {
            // Medal
            Text(medal)
                .font(.system(size: 30))
            
            // Team info - Show only player names
            VStack(spacing: 4) {
                Text(positionTitle(position))
                    .font(.caption.bold())
                    .foregroundColor(color)
                    .tracking(1)
                
                VStack(spacing: 2) {
                    Text(team.player1.name)
                        .font(.subheadline.bold())
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text("&")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(team.player2.name)
                        .font(.subheadline.bold())
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            
            // Podium base
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.8), color.opacity(0.4)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: height)
                .cornerRadius(8, corners: [.topLeft, .topRight])
                .overlay(
                    Text("\(position)")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                )
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Shareable View (Optimized for export)
    
    @ViewBuilder
    private var shareableResultsView: some View {
        VStack(spacing: 20) {
            // Compact header for sharing
            VStack(spacing: 6) {
                Text("🏆 " + tournament.name.uppercased() + " 🏆")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text("FINAL RESULTS")
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
                    .tracking(1.5)
            }
            
            // Simplified podium for export
            podiumView
            
            // Essential info
            HStack {
                Text(DateFormatter.celebrationDate.string(from: tournament.createdAt))
                    .font(.caption)
                
                Spacer()
                
                Text("\(tournament.teams.count) Teams")
                    .font(.caption)
                
                if let finalScore = finalScore {
                    Spacer()
                    Text("Final: \(finalScore.team1Score)-\(finalScore.team2Score)")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                }
            }
            .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(width: 350, height: 400) // Fixed size for consistent sharing
        .background(.white)
    }
    
    // MARK: - Share Button
    
    @ViewBuilder
    private var shareButton: some View {
        Button(action: {
            showingShareSheet = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                
                Text("Share Tournament Results")
                    .font(.headline.bold())
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(shareImage == nil)
    }
    
    // MARK: - Tournament Stats
    
    @ViewBuilder
    private var tournamentStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tournament Statistics")
                .font(.headline.bold())
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(title: "Total Matches", value: "\(tournament.matches.count)", color: .blue)
                StatCard(title: "Groups", value: "\(tournament.numberOfGroups)", color: .green)
                StatCard(title: "Courts Used", value: "\(tournament.courts)", color: .orange)
                StatCard(title: "Set Type", value: tournament.setType.rawValue.capitalized, color: .purple)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
    }
    
    // MARK: - Helper Methods
    
    private func positionTitle(_ position: Int) -> String {
        switch position {
        case 1: return "CHAMPIONS"
        case 2: return "RUNNERS-UP"
        case 3: return "THIRD PLACE"
        default: return "POSITION \(position)"
        }
    }
    
    private func captureResultsAsImage() {
        // Capture the shareable view as an image
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let renderer = ImageRenderer(content: shareableResultsView)
            renderer.scale = 3.0 // High resolution for sharing
            
            if let image = renderer.uiImage {
                shareImage = image
            }
        }
    }
    
    private func createShareText() -> String {
        func formatTeamNames(_ team: Team) -> String {
            return "\(team.player1.name) & \(team.player2.name)"
        }
        
        let championText = topTeams.count > 0 ? formatTeamNames(topTeams[0]) : "Unknown"
        
        return """
        🏆 \(tournament.name) - Tournament Results 🏆
        
        🥇 Champions: \(championText)
        \(topTeams.count > 1 ? "🥈 Runners-up: " + formatTeamNames(topTeams[1]) : "")
        \(topTeams.count > 2 ? "🥉 Third Place: " + formatTeamNames(topTeams[2]) : "")
        
        📅 \(DateFormatter.celebrationDate.string(from: tournament.createdAt))
        🎾 \(tournament.teams.count) teams competed
        \(finalScore != nil ? "📊 Final Score: \(finalScore!.team1Score)-\(finalScore!.team2Score)" : "")
        
        #PadelTournament #Champions
        """
    }
}

// MARK: - Supporting Views

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension DateFormatter {
    static let celebrationDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    let sampleTournament = Tournament(
        id: "sample",
        name: "Summer Championship 2026",
        courts: 4,
        numberOfGroups: 2,
        setType: .short,
        status: .completed,
        createdAt: Date(),
        courtAssignmentStrategy: .automatic
    )
    
    let sampleTeams = [
        Team(id: "1", name: "Alpha Force", player1: Player(id: "1", name: "John Doe"), player2: Player(id: "2", name: "Jane Smith")),
        Team(id: "2", name: "Beta Squad", player1: Player(id: "3", name: "Mike Johnson"), player2: Player(id: "4", name: "Sarah Wilson")),
        Team(id: "3", name: "Gamma Pro", player1: Player(id: "5", name: "Alex Brown"), player2: Player(id: "6", name: "Lisa Davis"))
    ]
    
    return TournamentResultsShareView(
        tournament: sampleTournament,
        topTeams: sampleTeams,
        finalScore: (team1Score: 6, team2Score: 4)
    )
}