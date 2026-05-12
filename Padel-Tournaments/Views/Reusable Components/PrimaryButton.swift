//
//  PrimaryButton.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var style: ButtonStyle = .filled
    
    enum ButtonStyle {
        case filled
        case outlined
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: style == .outlined ? 2 : 0)
                )
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .filled:
            return .white
        case .outlined:
            return .accentColor
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .filled:
            return .accentColor
        case .outlined:
            return .clear
        }
    }
    
    private var borderColor: Color {
        return .accentColor
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Create Tournament") { }
        PrimaryButton(title: "Join Tournament", action: { }, style: .outlined)
        PrimaryButton(title: "Disabled Button", action: { }, isEnabled: false)
    }
    .padding()
}