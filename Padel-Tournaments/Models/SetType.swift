//
//  SetType.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//


enum SetType: String, Codable {
    case short  // first to 4
    case long   // first to 6

    var target: Int {
        switch self {
        case .short: return 4
        case .long:  return 6
        }
    }
}