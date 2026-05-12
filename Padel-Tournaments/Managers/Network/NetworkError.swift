//
//  NetworkError.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case noInternetConnection
    case serverError(String)
    case decodingError
    case unauthorized
    case notFound
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection available"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "Failed to process server response"
        case .unauthorized:
            return "Unauthorized access"
        case .notFound:
            return "Resource not found"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}