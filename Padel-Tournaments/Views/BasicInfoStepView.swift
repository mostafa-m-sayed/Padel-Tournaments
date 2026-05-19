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
                        Text("Number of Groups")
                            .font(.headline)
                        
                        HStack {
                            Button {
                                if viewModel.numberOfGroups > 2 {
                                    viewModel.numberOfGroups -= 1
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                                    .font(.title2)
                                    .foregroundColor(viewModel.numberOfGroups > 2 ? .accentColor : .gray)
                            }
                            .disabled(viewModel.numberOfGroups <= 2)
                            
                            Spacer()
                            
                            Text("\(viewModel.numberOfGroups)")
                                .font(.title.bold())
                                .frame(minWidth: 40)
                            
                            Spacer()
                            
                            Button {
                                if viewModel.numberOfGroups < 8 {
                                    viewModel.numberOfGroups += 1
                                }
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(viewModel.numberOfGroups < 8 ? .accentColor : .gray)
                            }
                            .disabled(viewModel.numberOfGroups >= 8)
                        }
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        Text("More groups allow for different tournament formats like Americano")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Court Assignment Strategy")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            ForEach(CourtAssignmentStrategy.allCases, id: \.self) { strategy in
                                CourtStrategyCard(
                                    strategy: strategy,
                                    isSelected: viewModel.courtAssignmentStrategy == strategy,
                                    numberOfCourts: viewModel.numberOfCourts,
                                    numberOfGroups: viewModel.numberOfGroups
                                ) {
                                    viewModel.courtAssignmentStrategy = strategy
                                }
                            }
                        }
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

struct CourtStrategyCard: View {
    let strategy: CourtAssignmentStrategy
    let isSelected: Bool
    let numberOfCourts: Int
    let numberOfGroups: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(strategy.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? .accentColor : .gray)
                }
                
                Text(strategy.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                // Strategy-specific info
                HStack {
                    Image(systemName: strategy.iconName)
                        .foregroundColor(.blue)
                    
                    Text(strategy.statusText(courts: numberOfCourts, groups: numberOfGroups))
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
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

extension CourtAssignmentStrategy {
    var description: String {
        switch self {
        case .perGroup:
            return "Each group plays on a dedicated court. Good for keeping group matches together."
        case .distributed:
            return "Matches are distributed across all courts to minimize idle time."
        case .automatic:
            return "System automatically chooses the best strategy based on courts and groups."
        }
    }
    
    var iconName: String {
        switch self {
        case .perGroup: return "rectangle.3.group"
        case .distributed: return "arrow.trianglehead.2.clockwise"
        case .automatic: return "brain.head.profile"
        }
    }
    
    func statusText(courts: Int, groups: Int) -> String {
        switch self {
        case .perGroup:
            if groups > courts {
                return "Some courts will handle multiple groups"
            } else if groups < courts {
                return "\(courts - groups) court(s) may be idle"
            } else {
                return "Perfect match: 1 court per group"
            }
        case .distributed:
            return "All \(courts) courts will be utilized"
        case .automatic:
            let recommendedStrategy = groups >= courts ? "Per Group" : "Distributed"
            return "Will use: \(recommendedStrategy)"
        }
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
