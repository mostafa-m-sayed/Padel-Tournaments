//
//  SchedulePDFExporter.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 16/06/2026.
//

import UIKit
import PDFKit

/// Generates a PDF of the schedule table for a given set of rounds and matches.
struct SchedulePDFExporter {

    // MARK: - Layout constants

    private static let pageWidth:   CGFloat = 842   // A4 landscape
    private static let pageHeight:  CGFloat = 595
    private static let margin:      CGFloat = 32
    private static let rowHeight:   CGFloat = 80
    private static let roundColW:   CGFloat = 60
    private static let courtColW:   CGFloat = 200
    private static let headerH:     CGFloat = 36

    // MARK: - Colours (matching the SwiftUI palette)

    private static func groupColor(for groupId: String) -> UIColor {
        switch groupId {
        case "A": return UIColor.systemBlue
        case "B": return UIColor.systemGreen
        case "C": return UIColor.systemOrange
        case "D": return UIColor.systemPurple
        default:  return UIColor.systemGray
        }
    }

    // MARK: - Public API

    /// Generates a PDF `Data` blob for the schedule.
    ///
    /// - Parameters:
    ///   - title:            Tournament name shown at the top of the PDF.
    ///   - groupLabel:       "All Groups" or "Group X" — shown in the subtitle.
    ///   - rounds:           Ordered pairs `(roundNumber, [Match])`.
    ///   - courts:           Total number of courts (determines column count).
    ///   - teams:            All teams so we can resolve IDs → display names.
    ///   - showGroupBadge:   When showing all groups, colour-code each cell by group.
    static func generatePDF(
        title: String,
        groupLabel: String,
        rounds: [(Int, [Match])],
        courts: Int,
        teams: [Team],
        showGroupBadge: Bool
    ) -> Data {

        // ── Dynamic page width based on court count ────────────────────────
        let tableWidth = roundColW + CGFloat(courts) * courtColW
        let contentWidth = tableWidth
        let dynamicPageWidth = max(pageWidth, contentWidth + margin * 2)

        let pageRect = CGRect(x: 0, y: 0, width: dynamicPageWidth, height: pageHeight)
        let renderer  = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { ctx in
            var yOffset: CGFloat = margin

            // Helper: start a fresh PDF page
            func newPage() {
                ctx.beginPage()
                yOffset = margin
            }

            newPage()

            // ── Title ──────────────────────────────────────────────────────
            yOffset = drawTitle(
                title: title,
                subtitle: "Schedule · \(groupLabel)",
                pageRect: pageRect,
                yOffset: yOffset
            )
            yOffset += 12

            // ── Table header ───────────────────────────────────────────────
            yOffset = drawTableHeader(
                courts: courts,
                pageRect: pageRect,
                startX: margin,
                yOffset: yOffset
            )

            // ── Round rows ─────────────────────────────────────────────────
            for (round, matches) in rounds {
                // Page break check
                if yOffset + rowHeight > pageRect.height - margin {
                    // Re-draw header on the new page for readability
                    newPage()
                    yOffset = drawTableHeader(
                        courts: courts,
                        pageRect: pageRect,
                        startX: margin,
                        yOffset: yOffset
                    )
                }

                yOffset = drawRoundRow(
                    round: round,
                    matches: matches,
                    courts: courts,
                    teams: teams,
                    showGroupBadge: showGroupBadge,
                    startX: margin,
                    yOffset: yOffset,
                    pageRect: pageRect
                )
            }

            // ── Footer ─────────────────────────────────────────────────────
            drawFooter(pageRect: pageRect)
        }

        return data
    }

    // MARK: - Drawing helpers

    @discardableResult
    private static func drawTitle(
        title: String,
        subtitle: String,
        pageRect: CGRect,
        yOffset: CGFloat
    ) -> CGFloat {
        var y = yOffset

        // Title
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        let titleStr = NSAttributedString(string: title, attributes: titleAttrs)
        let titleSize = titleStr.boundingRect(
            with: CGSize(width: pageRect.width - 64, height: 40),
            options: .usesLineFragmentOrigin, context: nil
        )
        titleStr.draw(at: CGPoint(x: 32, y: y))
        y += titleSize.height + 4

        // Subtitle
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let subStr = NSAttributedString(string: subtitle, attributes: subAttrs)
        subStr.draw(at: CGPoint(x: 32, y: y))
        y += 20

        return y
    }

    @discardableResult
    private static func drawTableHeader(
        courts: Int,
        pageRect: CGRect,
        startX: CGFloat,
        yOffset: CGFloat
    ) -> CGFloat {
        let headerRect = CGRect(x: startX, y: yOffset,
                                width: roundColW + CGFloat(courts) * courtColW,
                                height: headerH)

        // Background
        UIColor.systemGray5.setFill()
        UIBezierPath(roundedRect: headerRect, cornerRadius: 4).fill()

        let textAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: UIColor.label
        ]

        // "Round" column
        drawCenteredText("Round", in: CGRect(x: startX, y: yOffset, width: roundColW, height: headerH), attrs: textAttrs)

        // Court columns
        for court in 1...courts {
            let x = startX + roundColW + CGFloat(court - 1) * courtColW
            drawCenteredText("Court \(court)",
                             in: CGRect(x: x, y: yOffset, width: courtColW, height: headerH),
                             attrs: textAttrs)

            // Vertical divider
            if court < courts {
                UIColor.separator.setStroke()
                let path = UIBezierPath()
                path.move(to: CGPoint(x: x + courtColW, y: yOffset))
                path.addLine(to: CGPoint(x: x + courtColW, y: yOffset + headerH))
                path.lineWidth = 0.5
                path.stroke()
            }
        }

        // Outer border
        UIColor.separator.setStroke()
        UIBezierPath(roundedRect: headerRect, cornerRadius: 4).stroke()

        return yOffset + headerH
    }

    @discardableResult
    private static func drawRoundRow(
        round: Int,
        matches: [Match],
        courts: Int,
        teams: [Team],
        showGroupBadge: Bool,
        startX: CGFloat,
        yOffset: CGFloat,
        pageRect: CGRect
    ) -> CGFloat {
        let rowRect = CGRect(x: startX, y: yOffset,
                             width: roundColW + CGFloat(courts) * courtColW,
                             height: rowHeight)

        // Row background (alternating)
        let bg: UIColor = round.isMultiple(of: 2) ? UIColor.systemGray6 : UIColor.systemBackground
        bg.setFill()
        UIRectFill(rowRect)

        // Round number
        let roundAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        drawCenteredText("\(round)",
                         in: CGRect(x: startX, y: yOffset, width: roundColW, height: rowHeight),
                         attrs: roundAttrs)

        // Court cells
        for court in 1...courts {
            let x = startX + roundColW + CGFloat(court - 1) * courtColW
            let cellRect = CGRect(x: x + 4, y: yOffset + 6,
                                  width: courtColW - 8, height: rowHeight - 12)

            if let match = matches.first(where: { $0.court == court }) {
                drawMatchCell(match: match, teams: teams,
                              showGroupBadge: showGroupBadge,
                              in: cellRect)
            } else {
                // Empty cell
                let emptyAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18),
                    .foregroundColor: UIColor.tertiaryLabel
                ]
                drawCenteredText("—", in: CGRect(x: x, y: yOffset, width: courtColW, height: rowHeight), attrs: emptyAttrs)
            }

            // Vertical divider
            if court < courts {
                UIColor.separator.setStroke()
                let path = UIBezierPath()
                path.move(to: CGPoint(x: x + courtColW, y: yOffset))
                path.addLine(to: CGPoint(x: x + courtColW, y: yOffset + rowHeight))
                path.lineWidth = 0.5
                path.stroke()
            }
        }

        // Row border
        UIColor.separator.setStroke()
        let borderPath = UIBezierPath(rect: rowRect)
        borderPath.lineWidth = 0.5
        borderPath.stroke()

        return yOffset + rowHeight
    }

    private static func drawMatchCell(
        match: Match,
        teams: [Team],
        showGroupBadge: Bool,
        in rect: CGRect
    ) {
        let color = showGroupBadge ? groupColor(for: match.groupId ?? "") : UIColor.systemBlue

        // Cell background
        color.withAlphaComponent(0.06).setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: 6).fill()

        // Border
        color.withAlphaComponent(0.35).setStroke()
        let borderPath = UIBezierPath(roundedRect: rect, cornerRadius: 6)
        borderPath.lineWidth = 1
        borderPath.stroke()

        var y = rect.minY + 6

        // Group badge
        if let groupId = match.groupId {
            let badgeText = "Group \(groupId)\(match.isPlayed ? "  ✓" : "")"
            let badgeAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 8, weight: .semibold),
                .foregroundColor: color
            ]
            let badgeStr = NSAttributedString(string: badgeText, attributes: badgeAttrs)
            let badgeSize = badgeStr.boundingRect(with: CGSize(width: rect.width - 8, height: 14),
                                                   options: .usesLineFragmentOrigin, context: nil)

            // Badge pill background
            color.withAlphaComponent(0.15).setFill()
            UIBezierPath(roundedRect: CGRect(x: rect.minX + 4, y: y, width: badgeSize.width + 8, height: 14),
                         cornerRadius: 3).fill()

            badgeStr.draw(at: CGPoint(x: rect.minX + 8, y: y + 2))
            y += 18
        }

        // Teams & scores
        let team1Name = teams.first(where: { $0.id == match.team1Id })?.displayName ?? "TBD"
        let team2Name = teams.first(where: { $0.id == match.team2Id })?.displayName ?? "TBD"

        drawTeamRow(name: team1Name, score: match.score1,
                    otherScore: match.score2,
                    in: CGRect(x: rect.minX + 4, y: y, width: rect.width - 8, height: 16))
        y += 17

        // "vs" separator
        let vsAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8, weight: .bold),
            .foregroundColor: UIColor.secondaryLabel
        ]
        NSAttributedString(string: "vs", attributes: vsAttrs)
            .draw(at: CGPoint(x: rect.minX + 6, y: y))
        y += 13

        drawTeamRow(name: team2Name, score: match.score2,
                    otherScore: match.score1,
                    in: CGRect(x: rect.minX + 4, y: y, width: rect.width - 8, height: 16))
    }

    private static func drawTeamRow(
        name: String,
        score: Int?,
        otherScore: Int?,
        in rect: CGRect
    ) {
        // Determine if this team won (bold score)
        let isWinner: Bool = {
            guard let s = score, let o = otherScore else { return false }
            return s > o
        }()

        let nameAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        let nameStr = NSAttributedString(string: name, attributes: nameAttrs)
        // Clip name to leave room for score
        let nameRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width - 28, height: rect.height)
        nameStr.draw(with: nameRect, options: .truncatesLastVisibleLine, context: nil)

        // Score
        if let score {
            let scoreAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: isWinner ? .bold : .regular),
                .foregroundColor: isWinner ? UIColor.label : UIColor.secondaryLabel
            ]
            let scoreStr = NSAttributedString(string: "\(score)", attributes: scoreAttrs)
            let scoreSize = scoreStr.boundingRect(with: CGSize(width: 24, height: rect.height),
                                                   options: .usesLineFragmentOrigin, context: nil)
            scoreStr.draw(at: CGPoint(x: rect.maxX - scoreSize.width, y: rect.minY))
        }
    }

    private static func drawFooter(pageRect: CGRect) {
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.tertiaryLabel
        ]

        let dateStr = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        let footerStr = NSAttributedString(string: "Generated \(dateStr) · Padel Tournaments", attributes: footerAttrs)
        footerStr.draw(at: CGPoint(x: 32, y: pageRect.height - 24))
    }

    // MARK: - Utility

    private static func drawCenteredText(
        _ text: String,
        in rect: CGRect,
        attrs: [NSAttributedString.Key: Any]
    ) {
        let str = NSAttributedString(string: text, attributes: attrs)
        let size = str.boundingRect(with: rect.size, options: .usesLineFragmentOrigin, context: nil)
        let x = rect.minX + (rect.width  - size.width)  / 2
        let y = rect.minY + (rect.height - size.height) / 2
        str.draw(at: CGPoint(x: x, y: y))
    }
}
