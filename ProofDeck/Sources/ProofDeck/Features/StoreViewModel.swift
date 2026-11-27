//
//  StoreViewModel.swift
//  ProofDeck
//
//  Observable adapter between the local store protocol and SwiftUI screens. It
//  keeps a published snapshot; every read and write still goes through
//  `StoreProtocol`, so the later SwiftData-backed store swap does not touch the
//  views. Local-first: no account, network or StoreKit state lives here.
//

import Foundation
import SwiftUI

@MainActor
final class StoreViewModel: ObservableObject {

    @Published private(set) var assets: [Asset] = []
    @Published var searchText: String = ""

    private let store: StoreProtocol

    init(store: StoreProtocol = PersistenceController.shared.makeStore()) {
        self.store = store
        reload()
    }

    // MARK: - Reads

    /// Featured first, then most recently updated; filtered by the active search
    /// term when one is entered.
    var filteredAssets: [Asset] {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let sorted = AssetSorter.sorted(store.assets())
        guard !term.isEmpty else { return sorted }
        return sorted.filter { AssetSorter.matches($0, term: term) }
    }

    func asset(id: UUID) -> Asset? {
        store.asset(id: id)
    }

    func clips(for assetID: UUID) -> [ReuseClip] {
        ClipSorter.sorted(store.clips(for: assetID))
    }

    func summary(for asset: Asset) -> String {
        CaseSummaryDraft.ruleTemplate(for: asset)
    }

    /// Full CSV snapshot for on-device export / sharing.
    func csvSnapshot() -> String {
        CsvBuilder.assetsCSV(store.assets())
    }

    // MARK: - Writes

    func save(_ asset: Asset) {
        if store.asset(id: asset.id) == nil {
            store.addAsset(asset)
        } else {
            store.updateAsset(asset)
        }
        reload()
    }

    func delete(id: UUID) {
        store.deleteAsset(id: id)
        reload()
    }

    func toggleFeatured(_ asset: Asset) {
        var updated = asset
        updated.status = asset.status == .featured ? .archived : .featured
        updated.updatedAt = Date()
        store.updateAsset(updated)
        reload()
    }

    func addClip(_ clip: ReuseClip) {
        store.addClip(clip)
        store.markReused(id: clip.assetID, at: Date())
        reload()
    }

    private func reload() {
        assets = AssetSorter.sorted(store.assets())
    }
}
