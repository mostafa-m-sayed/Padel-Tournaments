//
//  ShareSheet.swift
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 16/06/2026.
//

import SwiftUI
import UIKit

/// A SwiftUI wrapper around `UIActivityViewController` for sharing items.
struct ShareSheet: UIViewControllerRepresentable {

    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
