//
//  JoinTournamentView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct JoinTournamentView: View {
    @StateObject private var viewModel = JoinTournamentViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var tournamentId = ""
    @State private var showingTournament = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                    
                    VStack(spacing: 8) {
                        Text("Join Tournament")
                            .font(.largeTitle.bold())
                        
                        Text("Enter the tournament ID to join and participate")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Input Section
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tournament ID")
                            .font(.headline)
                        
                        TextField("Enter tournament ID", text: $tournamentId)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .onSubmit {
                                joinTournament()
                            }
                    }
                    
                    // Join Button
                    Button(action: joinTournament) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            
                            Text(viewModel.isLoading ? "Joining..." : "Join Tournament")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: tournamentId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading
                                    ? [.gray, .gray]
                                    : [.accentColor, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .disabled(tournamentId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Helper Text
                VStack(spacing: 8) {
                    Text("Need a tournament ID?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Ask the tournament organizer for the ID or check your invitation")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Join Tournament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Tournament Not Found", isPresented: Binding<Bool>(
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
        .fullScreenCover(isPresented: $showingTournament) {
            if let tournament = viewModel.foundTournament {
                NavigationStack {
                    TournamentDetailView(initialTournament: tournament, showBackButton: false)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Back to Home") {
                                    showingTournament = false
                                    dismiss()
                                }
                            }
                        }
                }
            }
        }
        .onReceive(viewModel.$foundTournament) { tournament in
            if tournament != nil {
                showingTournament = true
            }
        }
    }
    
    private func joinTournament() {
        let cleanId = tournamentId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanId.isEmpty else { return }
        
        Task {
            await viewModel.joinTournament(id: cleanId)
        }
    }
}

#Preview {
    JoinTournamentView()
}