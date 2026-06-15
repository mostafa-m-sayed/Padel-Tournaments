//
//  TournamentIdView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct TournamentIdView: View {
    let tournamentId: String
    @State private var showCopiedFeedback = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Tournament ID")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: copyToClipboard) {
                    HStack(spacing: 4) {
                        Image(systemName: showCopiedFeedback ? "checkmark" : "doc.on.doc")
                            .font(.caption)
                        Text(showCopiedFeedback ? "Copied!" : "Copy")
                            .font(.caption2.bold())
                    }
                    .foregroundColor(showCopiedFeedback ? .green : .accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(6)
                }
                .animation(.easeInOut(duration: 0.2), value: showCopiedFeedback)
            }
            
            HStack {
                Text(formattedId)
                    .font(.system(.title3, design: .monospaced))
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
                
                Spacer()
                
                Image(systemName: "qrcode")
                    .foregroundColor(.secondary)
                    .font(.title3)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.gray.opacity(0.08))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.2), lineWidth: 1)
            )
            
            Text("Share this ID with others so they can join the tournament")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 4)
    }
    
    private var formattedId: String {
        // Format the ID for better readability (e.g., ABCD-EFGH-IJKL)
        let cleanId = tournamentId.uppercased().replacingOccurrences(of: "-", with: "")
        let chunks = cleanId.chunked(into: 4)
        return chunks.joined(separator: "-")
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = tournamentId
        
        withAnimation(.easeInOut(duration: 0.2)) {
            showCopiedFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showCopiedFeedback = false
            }
        }
    }
}

// String extension for chunking
extension String {
    func chunked(into size: Int) -> [String] {
        return stride(from: 0, to: count, by: size).map {
            let start = index(startIndex, offsetBy: $0)
            let end = index(start, offsetBy: min(size, count - $0))
            return String(self[start..<end])
        }
    }
}

#Preview {
    VStack {
        TournamentIdView(tournamentId: "ABC123DEF456")
            .padding()
        
        Divider()
        
        TournamentIdView(tournamentId: "XYZ789UVW012QRS345")
            .padding()
    }
}