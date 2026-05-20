//
//  TournamentListView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct TournamentListView: View {
    @StateObject private var viewModel = TournamentListViewModel()
    @State private var showCreateTournament = false
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                LoadingView("Loading tournaments...")
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel.refreshTournaments()
                    }
                }
            } else if viewModel.tournaments.isEmpty {
                emptyStateView
            } else {
                tournamentListView
            }
        }
        .navigationTitle("Tournaments")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showCreateTournament = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .refreshable {
            await viewModel.refreshTournaments()
        }
        .task {
            await viewModel.loadTournaments()
        }
        .sheet(isPresented: $showCreateTournament) {
            CreateTournamentView()
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.error != nil },
            set: { _ in viewModel.clearError() }
        )) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Tournaments Yet")
                    .font(.title2.bold())
                
                Text("Create your first tournament to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            PrimaryButton(title: "Create Tournament") {
                showCreateTournament = true
            }
            .frame(maxWidth: 200)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var tournamentListView: some View {
        List {
            ForEach(viewModel.tournaments) { tournament in
                NavigationLink {
                    TournamentDetailView(tournament: tournament)
                } label: {
                    TournamentRowView(tournament: tournament)
                }
            }
            .onDelete { indexSet in
                Task {
                    await viewModel.deleteTournament(at: indexSet)
                }
            }
        }
        .listStyle(.plain)
    }
}

struct TournamentRowView: View {
    let tournament: Tournament
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tournament.name)
                    .font(.headline)
                
                Spacer()
                
                StatusBadge(status: tournament.status)
            }
            
            HStack {
                Label("\(tournament.courts)", systemImage: "sportscourt")
                
                Spacer()
                
                Text(tournament.setType.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(6)
                
                Text(tournament.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}



#Preview {
    NavigationStack {
        TournamentListView()
    }
}
