//
//  TemporaryAppIcon.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

// Temporary app icon view for development
struct TemporaryAppIconView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.blue, .green],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
                // Tennis/Sport icon
                Image(systemName: "figure.tennis")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.white)
                
                // Trophy accent
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
            }
        }
        .frame(width: 120, height: 120)
        .cornerRadius(26) // iOS icon corner radius
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HStack(spacing: 20) {
        TemporaryAppIconView()
        
        // Different size for testing
        TemporaryAppIconView()
            .scaleEffect(0.5)
    }
    .padding()
}