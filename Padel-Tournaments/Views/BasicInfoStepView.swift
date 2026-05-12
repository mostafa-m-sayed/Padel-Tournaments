//
//  BasicInfoStepView.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct BasicInfoStepView: View {
    @ObservedObject var viewModel: CreateTournamentViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "trophy.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("Tournament Details")
                        .font(.title2.bold())
                    
                    Text("Let's start by setting up your tournament basics")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tournament Name")
                            .font(.headline)
                        
                        TextField("Enter tournament name", text: $viewModel.tournamentName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number of Courts")
                            .font(.headline)
                        
                        HStack {
                            Button {
                                if viewModel.numberOfCourts > 1 {
                                    viewModel.numberOfCourts -= 1
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                                    .font(.title2)
                                    .foregroundColor(viewModel.numberOfCourts > 1 ? .accentColor : .gray)
                            }
                            .disabled(viewModel.numberOfCourts <= 1)
                            
                            Spacer()
                            
                            Text("\(viewModel.numberOfCourts)")
                                .font(.title.bold())
                                .frame(minWidth: 40)
                            
                            Spacer()
                            
                            Button {
                                if viewModel.numberOfCourts < 10 {
                                    viewModel.numberOfCourts += 1
                                }
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(viewModel.numberOfCourts < 10 ? .accentColor : .gray)
                            }
                            .disabled(viewModel.numberOfCourts >= 10)
                        }
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Set Type")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            SetTypeCard(
                                setType: .short,
                                isSelected: viewModel.setType == .short
                            ) {
                                viewModel.setType = .short
                            }
                            
                            SetTypeCard(
                                setType: .long,
                                isSelected: viewModel.setType == .long
                            ) {
                                viewModel.setType = .long
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SetTypeCard: View {
    let setType: SetType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(setType.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(setType.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .accentColor : .gray)
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : .gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

extension SetType {
    var displayName: String {
        switch self {
        case .short: return "Short Sets"
        case .long: return "Long Sets"
        }
    }
    
    var description: String {
        switch self {
        case .short: return "First to \(target) games"
        case .long: return "First to \(target) games"
        }
    }
}

#Preview {
    BasicInfoStepView(viewModel: CreateTournamentViewModel())
}
