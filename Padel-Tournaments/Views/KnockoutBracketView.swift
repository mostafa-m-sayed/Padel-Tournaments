//
//  KnockoutBracketView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 30/06/2026.
//

import SwiftUI

/// Visual bracket for the knockout stage: two semifinals on the left,
/// connector lines, then the final on the right. The third-place playoff
/// is shown as a small companion bracket below.
struct KnockoutBracketView: View {
    let semifinals: [Match]
    let finalMatch: Match?
    let thirdPlaceMatch: Match?
    let teams: [Team]
    let onTapMatch: (Match) -> Void

    private let nodeWidth: CGFloat = 200
    private let nodeHeight: CGFloat = 96
    private let semiGap: CGFloat = 56
    private let connectorWidth: CGFloat = 56

    private var orderedSemis: [Match] {
        semifinals.sorted { lhs, rhs in
            if lhs.round != rhs.round { return lhs.round < rhs.round }
            return lhs.court < rhs.court
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "rectangle.split.3x1")
                    .foregroundColor(.purple)
                Text("Bracket")
                    .font(.title2.bold())
                    .foregroundColor(.purple)
            }

            ScrollView(.horizontal, showsIndicators: true) {
                mainBracket
                    .padding(.vertical, 8)
            }

            if let thirdPlaceMatch {
                thirdPlaceSection(match: thirdPlaceMatch)
            }
        }
        .padding()
        .background(Color.purple.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Main bracket

    @ViewBuilder
    private var mainBracket: some View {
        let bracketHeight = nodeHeight * 2 + semiGap

        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 8) {
                stageLabel("Semifinals", color: .purple)
                VStack(spacing: semiGap) {
                    ForEach(orderedSemis.indices, id: \.self) { index in
                        BracketMatchNode(
                            match: orderedSemis[index],
                            label: "Semi \(index + 1)",
                            teams: teams,
                            accent: .purple,
                            width: nodeWidth,
                            height: nodeHeight,
                            onTap: onTapMatch
                        )
                    }
                }
                .frame(height: bracketHeight, alignment: .top)
            }

            VStack(spacing: 8) {
                Spacer().frame(height: stageLabelHeight)
                BracketConnector()
                    .stroke(Color.purple.opacity(0.5), lineWidth: 2)
                    .frame(width: connectorWidth, height: bracketHeight)
            }

            VStack(spacing: 8) {
                stageLabel("Final", color: .gold)
                ZStack {
                    Color.clear.frame(height: bracketHeight)
                    if let finalMatch {
                        BracketMatchNode(
                            match: finalMatch,
                            label: "Final",
                            teams: teams,
                            accent: .gold,
                            width: nodeWidth,
                            height: nodeHeight,
                            onTap: onTapMatch
                        )
                    } else {
                        placeholderNode(label: "Final", color: .gold)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func thirdPlaceSection(match: Match) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "medal.fill")
                    .foregroundColor(.orange)
                Text("Third Place Playoff")
                    .font(.headline.bold())
                    .foregroundColor(.orange)
            }

            BracketMatchNode(
                match: match,
                label: "3rd Place",
                teams: teams,
                accent: .orange,
                width: nodeWidth,
                height: nodeHeight,
                onTap: onTapMatch
            )
        }
    }

    // MARK: - Helpers

    private let stageLabelHeight: CGFloat = 28

    @ViewBuilder
    private func stageLabel(_ title: String, color: Color) -> some View {
        Text(title.uppercased())
            .font(.caption.bold())
            .tracking(1.2)
            .foregroundColor(color)
            .frame(height: stageLabelHeight)
    }

    @ViewBuilder
    private func placeholderNode(label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(color)
            Text("TBD")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(width: nodeWidth, height: nodeHeight)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        )
    }
}

// MARK: - Match Node

private struct BracketMatchNode: View {
    let match: Match
    let label: String
    let teams: [Team]
    let accent: Color
    let width: CGFloat
    let height: CGFloat
    let onTap: (Match) -> Void

    private var team1Display: String {
        displayName(for: match.team1Id)
    }

    private var team2Display: String {
        displayName(for: match.team2Id)
    }

    /// A match is tappable only when both teams are resolved (no TBD placeholders).
    private var canScore: Bool {
        !isPlaceholderId(match.team1Id) && !isPlaceholderId(match.team2Id)
    }

    private var team1IsWinner: Bool {
        match.isPlayed && (match.score1 ?? 0) > (match.score2 ?? 0)
    }

    private var team2IsWinner: Bool {
        match.isPlayed && (match.score2 ?? 0) > (match.score1 ?? 0)
    }

    var body: some View {
        Button {
            if canScore { onTap(match) }
        } label: {
            VStack(spacing: 0) {
                headerBar
                teamRow(name: team1Display, score: match.score1, isWinner: team1IsWinner)
                Divider()
                teamRow(name: team2Display, score: match.score2, isWinner: team2IsWinner)
            }
            .frame(width: width, height: height)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(match.isPlayed ? Color.green.opacity(0.5) : accent.opacity(0.4), lineWidth: 1)
            )
            .opacity(canScore || match.isPlayed ? 1 : 0.7)
        }
        .buttonStyle(.plain)
        .disabled(!canScore)
    }

    private var headerBar: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption2.bold())
                .foregroundColor(accent)
            Spacer()
            if match.isPlayed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.green)
            } else if canScore {
                Text("Court \(match.court)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("Pending")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(accent.opacity(0.1))
    }

    private func teamRow(name: String, score: Int?, isWinner: Bool) -> some View {
        HStack(spacing: 8) {
            Text(name)
                .font(.subheadline)
                .fontWeight(isWinner ? .semibold : .regular)
                .foregroundColor(isWinner ? .primary : .secondary)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer()
            if let score {
                Text("\(score)")
                    .font(.subheadline.bold())
                    .foregroundColor(isWinner ? .green : .primary)
                    .frame(minWidth: 22)
            } else {
                Text("–")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(minWidth: 22)
            }
        }
        .padding(.horizontal, 10)
        .frame(maxHeight: .infinity)
    }

    private func displayName(for teamId: String) -> String {
        if let team = teams.first(where: { $0.id == teamId }) {
            return team.displayName
        }
        return placeholderLabel(for: teamId)
    }

    private func placeholderLabel(for teamId: String) -> String {
        switch teamId {
        case "TBD_SEMI1_WINNER": return "Winner of Semi 1"
        case "TBD_SEMI2_WINNER": return "Winner of Semi 2"
        case "TBD_SEMI1_LOSER": return "Loser of Semi 1"
        case "TBD_SEMI2_LOSER": return "Loser of Semi 2"
        default: return "TBD"
        }
    }

    private func isPlaceholderId(_ id: String) -> Bool {
        id.hasPrefix("TBD_")
    }
}

// MARK: - Connector

/// Draws the connector lines that join the two semifinals to the final match.
/// Lines exit from the right edge of each semi, meet at the horizontal midpoint
/// of the connector column, then converge at the vertical midpoint of the
/// bracket and feed into the final.
#Preview("Bracket - semis in progress") {
    let teams = [
        Team(id: "t1", name: "A1", player1: Player(id: "p1", name: "Ali"), player2: Player(id: "p2", name: "Sara")),
        Team(id: "t2", name: "B2", player1: Player(id: "p3", name: "Omar"), player2: Player(id: "p4", name: "Mona")),
        Team(id: "t3", name: "B1", player1: Player(id: "p5", name: "Karim"), player2: Player(id: "p6", name: "Layla")),
        Team(id: "t4", name: "A2", player1: Player(id: "p7", name: "Hassan"), player2: Player(id: "p8", name: "Nour")),
    ]
    let semis: [Match] = [
        Match(id: "s1", court: 1, round: 1, stage: .semi, team1Id: "t1", team2Id: "t2", score1: 6, score2: 4, groupId: nil),
        Match(id: "s2", court: 2, round: 1, stage: .semi, team1Id: "t3", team2Id: "t4", score1: nil, score2: nil, groupId: nil),
    ]
    let finalMatch = Match(id: "f", court: 1, round: 3, stage: .final, team1Id: "t1", team2Id: "TBD_SEMI2_WINNER", score1: nil, score2: nil, groupId: nil)
    let thirdPlace = Match(id: "tp", court: 1, round: 2, stage: .thirdPlace, team1Id: "t2", team2Id: "TBD_SEMI2_LOSER", score1: nil, score2: nil, groupId: nil)
    return ScrollView {
        KnockoutBracketView(
            semifinals: semis,
            finalMatch: finalMatch,
            thirdPlaceMatch: thirdPlace,
            teams: teams
        ) { _ in }
        .padding()
    }
}

private struct BracketConnector: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // y positions: roughly aligned with the centers of the two semis.
        // The semis span the full bracket height (rect.height) with a gap
        // between them, but for a clean visual we anchor lines to the upper
        // and lower quarters so they hit the vertical center of each card.
        let topY = rect.height * 0.16
        let bottomY = rect.height * 0.84
        let midY = rect.height * 0.5
        let midX = rect.width * 0.5

        // Top semi → midpoint
        path.move(to: CGPoint(x: 0, y: topY))
        path.addLine(to: CGPoint(x: midX, y: topY))
        path.addLine(to: CGPoint(x: midX, y: midY))

        // Bottom semi → midpoint
        path.move(to: CGPoint(x: 0, y: bottomY))
        path.addLine(to: CGPoint(x: midX, y: bottomY))
        path.addLine(to: CGPoint(x: midX, y: midY))

        // Midpoint → final
        path.move(to: CGPoint(x: midX, y: midY))
        path.addLine(to: CGPoint(x: rect.width, y: midY))

        return path
    }
}
