//
//  ProofDeckApp.swift
//  ProofDeck
//
//  Composition root. The first skeleton wires the local store behind the
//  persistence protocol; feature tabs and settings views follow once the domain
//  screens are filled in. No StoreKit, account or remote service is wired here yet.
//

import SwiftUI

@main
struct ProofDeckApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Placeholder root view. Replace with the first real feature tab/flow.
struct RootView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "archivebox")
                .font(.largeTitle)
            Text("ProofDeck")
                .font(.title2)
            Text("Deliverable archive and reusable proof cards — skeleton.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
