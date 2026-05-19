//
//  TournamentStatus.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation
import SwiftUI

enum TournamentStatus: String, Codable, CaseIterable {
    case draft = "draft"
    case groupStage = "group_stage"
    case knockout = "knockout"
    case completed = "completed"
    
    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .groupStage: return "Group Stage"
        case .knockout: return "Knockout"
        case .completed: return "Completed"
        }
    }
    
    var description: String {
        switch self {
        case .draft: return "Tournament is being set up"
        case .groupStage: return "Group stage matches in progress"
        case .knockout: return "Knockout stage matches in progress"
        case .completed: return "Tournament has finished"
        }
    }
    
    var color: Color {
        switch self {
        case .draft: return .orange
        case .groupStage: return .blue
        case .knockout: return .purple
        case .completed: return .green
        }
    }
}
