//
//  ViewModelSpotlightTests.swift
//  ProofDeckTests
//
//  Verify the view model keeps the Spotlight index in sync: index on save,
//  remove on delete, and reindex when the featured flag toggles. The indexer is
//  faked so these tests stay offline and never touch the on-device index.
//

import XCTest
@testable import ProofDeck

private final class FakeSpotlight: SpotlightIndexerProtocol {
    var indexedAssets: [Asset] = []
    var removed: [UUID] = []
    var removeAllCount = 0

    func index(asset: Asset) { indexedAssets.append(asset) }
    func removeRecord(id: UUID) { removed.append(id) }
    func removeAll() { removeAllCount += 1 }
}

final class ViewModelSpotlightTests: XCTestCase {

    func testSaveNewAssetIsIndexed() async {
        await MainActor.run {
            let store = InMemoryStore()
            let fake = FakeSpotlight()
            let viewModel = StoreViewModel(store: store, spotlight: fake)
            let asset = Asset(projectTitle: "Website Redesign", skills: ["Branding"])

            viewModel.save(asset)

            XCTAssertEqual(fake.indexedAssets.map(\.id), [asset.id])
            XCTAssertEqual(store.assets().map(\.id), [asset.id])
        }
    }

    func testUpdateAssetIsReindexed() async {
        await MainActor.run {
            let store = InMemoryStore()
            let fake = FakeSpotlight()
            let viewModel = StoreViewModel(store: store, spotlight: fake)
            var asset = Asset(projectTitle: "Original")
            viewModel.save(asset)

            asset.reusableNotes = "Reusable notes"
            viewModel.save(asset)

            XCTAssertEqual(fake.indexedAssets.count, 2)
            XCTAssertEqual(fake.indexedAssets.last?.id, asset.id)
        }
    }

    func testDeleteAssetRemovesIndexedRecord() async {
        await MainActor.run {
            let store = InMemoryStore()
            let fake = FakeSpotlight()
            let viewModel = StoreViewModel(store: store, spotlight: fake)
            let asset = Asset(projectTitle: "Retainer")
            viewModel.save(asset)

            viewModel.delete(id: asset.id)

            XCTAssertEqual(fake.removed, [asset.id])
            XCTAssertTrue(store.assets().isEmpty)
        }
    }

    func testToggleFeaturedReindexesAsset() async {
        await MainActor.run {
            let store = InMemoryStore()
            let fake = FakeSpotlight()
            let viewModel = StoreViewModel(store: store, spotlight: fake)
            let asset = Asset(projectTitle: "Keynote", status: .archived)
            viewModel.save(asset)

            viewModel.toggleFeatured(asset)

            XCTAssertEqual(fake.indexedAssets.count, 2)
            let stored = store.asset(id: asset.id)
            XCTAssertEqual(stored?.status, .featured)
        }
    }
}
