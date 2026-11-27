//
//  WidgetSnapshotBuilder.swift
//  ProofDeck
//
//  Pure aggregation from the store protocol into the shared widget snapshot.
//  No SwiftUI, no WidgetKit here — the app calls `refresh` after every write,
//  and the widget reads the persisted snapshot in its own target.
//

import Foundation

enum WidgetSnapshotBuilder {

    /// Build a glanceable summary: total archived cards, how many are pinned
    /// featured, how many have been reused at least once, and the top three
    /// titles in the same ordering as the main list.
    static func snapshot(from store: StoreProtocol, now: Date = Date()) -> WidgetSnapshot {
        let assets = store.assets()
        let featured = assets.filter { $0.status == .featured }
        let reused = assets.filter { $0.lastReusedAt != nil }
        let topTitles = AssetSorter.sorted(assets).prefix(3).map { $0.projectTitle }

        return WidgetSnapshot(
            totalCount: assets.count,
            featuredCount: featured.count,
            reusedCount: reused.count,
            topTitles: topTitles,
            updatedAt: now
        )
    }

    /// Persist the fresh snapshot to the App Group container. The widget picks it
    /// up on its next timeline pass.
    static func refresh(from store: StoreProtocol, now: Date = Date()) {
        WidgetSnapshotStore.save(snapshot(from: store, now: now))
    }
}
