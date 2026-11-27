//
//  SwiftDataStoreTests.swift
//  ProofDeckTests
//
//  CRUD + cascade contract over an in-memory SwiftData container. The protocol
//  contract is also covered against `InMemoryStore`; these cases exercise the
//  SwiftData record mapping and persistence round trip without touching the
//  on-device store, WidgetKit or the index.
//

import XCTest
import SwiftData
@testable import ProofDeck

final class SwiftDataStoreTests: XCTestCase {

    private func makeStore() throws -> SwiftDataStore {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: SDAsset.self, SDClip.self,
            configurations: configuration
        )
        return SwiftDataStore(context: ModelContext(container))
    }

    private func makeAsset() -> Asset {
        Asset(
            projectTitle: "Renovation Case",
            clientName: "Acme",
            role: "Lead Designer",
            industry: "Construction",
            skills: ["Drafting", "Review"],
            deliverables: [Deliverable(title: "Drawings", kind: .file)],
            outcomes: [Outcome(metric: "Schedule", value: "12", unit: "weeks")],
            testimonial: Testimonial(quote: "On time", source: "PM", shareable: true),
            reusableNotes: "Reusable approach",
            mediaLinks: [MediaLink(url: "https://example.com")],
            status: .featured,
            sourceDealID: UUID()
        )
    }

    func testAddAndFetchAssetRoundTrip() throws {
        let store = try makeStore()
        let asset = makeAsset()
        store.addAsset(asset)

        let fetched = try XCTUnwrap(store.asset(id: asset.id))
        XCTAssertEqual(fetched, asset)
    }

    func testUpdateAssetPersistsChanges() throws {
        let store = try makeStore()
        var asset = makeAsset()
        store.addAsset(asset)

        asset.projectTitle = "Revised Title"
        asset.status = .archived
        asset.skills = ["Consultation"]
        store.updateAsset(asset)

        let fetched = try XCTUnwrap(store.asset(id: asset.id))
        XCTAssertEqual(fetched.projectTitle, "Revised Title")
        XCTAssertEqual(fetched.status, .archived)
        XCTAssertEqual(fetched.skills, ["Consultation"])
    }

    func testDeleteAssetCascadesClips() throws {
        let store = try makeStore()
        let asset = makeAsset()
        store.addAsset(asset)
        store.addClip(ReuseClip(assetID: asset.id, excerpt: "Method note", section: .method))
        store.addClip(ReuseClip(assetID: asset.id, excerpt: "Result note", section: .result))

        XCTAssertEqual(store.clips(for: asset.id).count, 2)

        store.deleteAsset(id: asset.id)

        XCTAssertTrue(store.assets().isEmpty)
        XCTAssertTrue(store.clips(for: asset.id).isEmpty)
    }

    func testMarkReusedSetsLastReusedAt() throws {
        let store = try makeStore()
        let asset = makeAsset()
        store.addAsset(asset)
        let reusedAt = Date(timeIntervalSinceNow: -1800)

        store.markReused(id: asset.id, at: reusedAt)

        let fetched = try XCTUnwrap(store.asset(id: asset.id))
        XCTAssertEqual(fetched.lastReusedAt, reusedAt)
    }

    func testClipRoundTripKeepsSectionAndExcerpt() throws {
        let store = try makeStore()
        let asset = makeAsset()
        store.addAsset(asset)
        let clip = ReuseClip(assetID: asset.id, excerpt: "Quote line", section: .quote)
        store.addClip(clip)

        let fetched = try XCTUnwrap(store.clips(for: asset.id).first)
        XCTAssertEqual(fetched, clip)
    }
}
