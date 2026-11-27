//
//  SpotlightService.swift
//  ProofDeck
//
//  System Spotlight indexing for archived asset cards. The protocol keeps the
//  view model decoupled from CoreSpotlight so indexing can be faked in offline
//  unit tests. Indexing is local-only; no record leaves the device.
//

import Foundation
import CoreSpotlight
import MobileCoreServices

protocol SpotlightIndexerProtocol: AnyObject {
    /// Index (or refresh) an asset card so it appears in system search.
    func index(asset: Asset)
    /// Remove a single indexed record by its record UUID.
    func removeRecord(id: UUID)
    /// Clear all indexed records.
    func removeAll()
}

/// CoreSpotlight-backed implementation. Uses the default on-device index.
final class SpotlightIndexer: SpotlightIndexerProtocol {
    static let shared = SpotlightIndexer()

    private let index: CSSearchableIndex

    init(index: CSSearchableIndex = .default()) {
        self.index = index
    }

    func index(asset: Asset) {
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        attributes.title = asset.projectTitle
        attributes.contentDescription = [asset.clientName, asset.role, asset.industry]
            .compactMap { $0 }
            .joined(separator: " · ")
        attributes.keywords = asset.skills

        let item = CSSearchableItem(
            uniqueIdentifier: asset.id.uuidString,
            domainIdentifier: "proofdeck.asset",
            attributeSet: attributes
        )
        index.indexSearchableItems([item])
    }

    func removeRecord(id: UUID) {
        index.deleteSearchableItems(withIdentifiers: [id.uuidString])
    }

    func removeAll() {
        index.deleteAllSearchableItems()
    }
}
