//
//  HomeView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showTournamentList = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "figure.tennis")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                    
                    VStack(spacing: 8) {
                        Text("Padel Tournaments")
                            .font(.largeTitle.bold())
                        
                        Text("Organize and manage your padel tournaments with ease")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
                .background(
                    LinearGradient(
                        colors: [.accentColor.opacity(0.1), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 20) {
                    PrimaryButton(title: "Create Tournament") {
                        viewModel.createTournamentTapped()
                    }
                    
                    PrimaryButton(
                        title: "Join Tournament",
                        action: { viewModel.joinTournamentTapped() },
                        style: .outlined
                    )
                    
                    Button("View All Tournaments") {
                        showTournamentList = true
                    }
                    .font(.headline)
                    .foregroundColor(.accentColor)
                    .padding()
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showCreateTournament) {
                CreateTournamentView()
            }
            .sheet(isPresented: $viewModel.showJoinTournament) {
                JoinTournamentView()
            }
            .fullScreenCover(isPresented: $showTournamentList) {
                NavigationStack {
                    TournamentListView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") {
                                    showTournamentList = false
                                }
                            }
                        }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
    }
}

#Preview {
    HomeView()
}