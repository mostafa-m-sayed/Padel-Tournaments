//
//  CreateTournamentView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct CreateTournamentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateTournamentViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Bar
                ProgressBarView(currentStep: viewModel.currentStep)
                
                // Step Content
                VStack {
                    switch viewModel.currentStep {
                    case .basicInfo:
                        BasicInfoStepView(viewModel: viewModel)
                    case .teamSetup:
                        TeamSetupStepView(viewModel: viewModel)
                    case .groupAssignment:
                        GroupAssignmentStepView(viewModel: viewModel)
                    }
                }
                .animation(.easeInOut, value: viewModel.currentStep)
            }
            .navigationTitle("Create Tournament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    navigationButton
                }
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.error != nil },
                set: { _ in viewModel.error = nil }
            )) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
    }
    
    @ViewBuilder
    private var navigationButton: some View {
        switch viewModel.currentStep {
        case .basicInfo:
            Button("Next") {
                viewModel.nextStep()
            }
            .disabled(!viewModel.canProceedFromBasicInfo)
            
        case .teamSetup:
            Button("Next") {
                viewModel.nextStep()
            }
            .disabled(!viewModel.canProceedFromTeamSetup)
            
        case .groupAssignment:
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Button("Create") {
                    Task {
                        await viewModel.createTournament()
                        if viewModel.error == nil {
                            dismiss()
                        }
                    }
                }
                .disabled(!viewModel.canCreateTournament)
            }
        }
    }
}

struct ProgressBarView: View {
    let currentStep: CreateTournamentViewModel.TournamentCreationStep
    
    private let steps: [CreateTournamentViewModel.TournamentCreationStep] = [
        .basicInfo, .teamSetup, .groupAssignment
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    Circle()
                        .fill(isStepCompleted(step) ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                    
                    if index < steps.count - 1 {
                        Rectangle()
                            .fill(isStepCompleted(steps[index + 1]) ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(height: 2)
                    }
                }
            }
            
            Text(stepTitle(currentStep))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private func isStepCompleted(_ step: CreateTournamentViewModel.TournamentCreationStep) -> Bool {
        let currentIndex = steps.firstIndex(of: currentStep) ?? 0
        let stepIndex = steps.firstIndex(of: step) ?? 0
        return stepIndex <= currentIndex
    }
    
    private func stepTitle(_ step: CreateTournamentViewModel.TournamentCreationStep) -> String {
        switch step {
        case .basicInfo: return "Tournament Details"
        case .teamSetup: return "Add Teams"
        case .groupAssignment: return "Assign Groups"
        }
    }
}

#Preview {
    CreateTournamentView()
}