//
//  Sorters.swift
//  ProofDeck
//
//  Pure, portable default ordering for the asset list. No SwiftUI, persistence
//  or network — tested off-device. Views wrap the store results here.
//

import Foundation

enum AssetSorter {
    /// Featured cards first; otherwise most recently updated first. Ties break
    /// by creation date descending.
    static func sorted(_ assets: [Asset]) -> [Asset] {
        assets.sorted { a, b in
            let featuredA = a.status == .featured
            let featuredB = b.status == .featured
            if featuredA != featuredB { return featuredA }
            if a.updatedAt != b.updatedAt { return a.updatedAt > b.updatedAt }
            return a.createdAt > b.createdAt
        }
    }

    /// Case-insensitive substring match across title, client, role, industry
    /// and skills. Pure so it can be unit-tested without a store.
    static func matches(_ asset: Asset, term: String) -> Bool {
        let haystack = [
            asset.projectTitle,
            asset.clientName ?? "",
            asset.role ?? "",
            asset.industry ?? "",
            asset.skills.joined(separator: " ")
        ].joined(separator: " ")
        return haystack.localizedCaseInsensitiveContains(term)
    }
}

enum ClipSorter {
    /// Newest clip first.
    static func sorted(_ clips: [ReuseClip]) -> [ReuseClip] {
        clips.sorted { $0.createdAt > $1.createdAt }
    }
}
