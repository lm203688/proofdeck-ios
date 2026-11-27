//
//  PersistenceController.swift
//  ProofDeck
//
//  Store protocol shared by the app, intents and offline tests. The production
//  entry point builds a SwiftData container; `InMemoryStore` remains a test /
//  preview stub that satisfies the same protocol.
//
//  Local-first; no CloudKit or account sync is enabled here.
//

import Foundation
import SwiftData

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

/// Shared persistence entry point backed by a SwiftData container. The store
/// protocol keeps views, intents and tests independent of the persistence layer;
/// `InMemoryStore` remains available as a test / preview stub.
final class PersistenceController {
    static let shared: PersistenceController = {
        do {
            return try PersistenceController()
        } catch {
            fatalError("Unable to initialize SwiftData ModelContainer: \(error)")
        }
    }()

    let container: ModelContainer

    private init() throws {
        container = try ModelContainer(for: SDAsset.self, SDClip.self)
    }

    var context: ModelContext { ModelContext(container) }

    func makeStore() -> StoreProtocol {
        SwiftDataStore(context: context)
    }
}
