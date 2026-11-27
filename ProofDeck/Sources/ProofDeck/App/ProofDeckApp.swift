//
//  ProofDeckApp.swift
//  ProofDeck
//
//  Composition root. The local store sits behind the persistence protocol; the
//  SwiftUI screens read and write through the shared `StoreViewModel`. No
//  StoreKit, account or remote service is wired here yet.
//

import SwiftUI

@main
struct ProofDeckApp: App {

    @StateObject private var viewModel: StoreViewModel

    init() {
        let store = PersistenceController.shared.makeStore()
        _viewModel = StateObject(wrappedValue: StoreViewModel(store: store))
        // Refresh the registered Siri / Shortcuts suggestions for the current intents.
        ProofDeckShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                AssetListView()
                    .tabItem {
                        Label("Archive", systemImage: "archivebox")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .environmentObject(viewModel)
        }
    }
}
