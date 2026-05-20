//
//  StatusBadge.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct StatusBadge: View {
    let status: TournamentStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            
            Text(status.displayName)
                .font(.caption.bold())
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 10) {
        StatusBadge(status: .draft)
        StatusBadge(status: .groupStage)
        StatusBadge(status: .knockout)
        StatusBadge(status: .completed)
    }
}