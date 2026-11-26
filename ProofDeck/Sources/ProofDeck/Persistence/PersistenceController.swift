//
//  PersistenceController.swift
//  ProofDeck
//
//  Store protocol and the first local implementation. The first skeleton ships
//  an in-memory store so the app, intents and offline tests compile without a
//  SwiftData container. The SwiftData-backed store and @Model records are added
//  in the next iteration; the protocol keeps that swap behind the same interface.
//
//  Local-first; no CloudKit or account sync is enabled here.
//

import Foundation

/// Read/write interface over the local asset cards and reuse clips.
protocol StoreProtocol: AnyObject {
    func assets() -> [Asset]
    func asset(id: UUID) -> Asset?
    func addAsset(_ asset: Asset)
    func updateAsset(_ asset: Asset)
    func deleteAsset(id: UUID)
    func clips(for assetID: UUID) -> [ReuseClip]
    func addClip(_ clip: ReuseClip)
    func markReused(id: UUID, at date: Date)
}

/// First local implementation: holds records in memory. Replaced by the
/// SwiftData store without changing call sites.
final class InMemoryStore: StoreProtocol {
    private var assetRecords: [Asset] = []
    private var clipRecords: [ReuseClip] = []

    func assets() -> [Asset] { assetRecords }

    func asset(id: UUID) -> Asset? { assetRecords.first { $0.id == id } }

    func addAsset(_ asset: Asset) {
        assetRecords.append(asset)
    }

    func updateAsset(_ asset: Asset) {
        guard let index = assetRecords.firstIndex(where: { $0.id == asset.id }) else { return }
        assetRecords[index] = asset
    }

    func deleteAsset(id: UUID) {
        assetRecords.removeAll { $0.id == id }
        clipRecords.removeAll { $0.assetID == id }
    }

    func clips(for assetID: UUID) -> [ReuseClip] {
        clipRecords.filter { $0.assetID == assetID }
    }

    func addClip(_ clip: ReuseClip) {
        clipRecords.append(clip)
    }

    func markReused(id: UUID, at date: Date) {
        guard let index = assetRecords.firstIndex(where: { $0.id == id }) else { return }
        assetRecords[index].lastReusedAt = date
    }
}

/// Shared persistence entry point. Replacing `makeStore()` with a SwiftData-backed
/// store does not affect the rest of the app.
final class PersistenceController {
    static let shared = PersistenceController()

    private let store: StoreProtocol

    private init(store: StoreProtocol = InMemoryStore()) {
        self.store = store
    }

    func makeStore() -> StoreProtocol { store }
}
