//
//  WidgetSnapshotBuilderTests.swift
//  ProofDeckTests
//
//  Verify the widget summary counts and title ordering without touching the
//  App Group container, WidgetKit or the on-device index.
//

import XCTest
@testable import ProofDeck

final class WidgetSnapshotBuilderTests: XCTestCase {

    private func makeStore() -> InMemoryStore { InMemoryStore() }

    func testSnapshotCountsFeaturedAndReused() throws {
        let store = makeStore()
        let featured = Asset(projectTitle: "Featured Case", status: .featured)
        let reused = Asset(projectTitle: "Reused Case", lastReusedAt: Date())
        let plain = Asset(projectTitle: "Plain Case")
        [featured, reused, plain].forEach { store.addAsset($0) }

        let snapshot = WidgetSnapshotBuilder.snapshot(from: store)

        XCTAssertEqual(snapshot.totalCount, 3)
        XCTAssertEqual(snapshot.featuredCount, 1)
        XCTAssertEqual(snapshot.reusedCount, 1)
        XCTAssertEqual(snapshot.topTitles.count, 3)
    }

    func testTopTitlesPutFeaturedFirst() {
        let store = makeStore()
        let archived = Asset(projectTitle: "Archived First", status: .archived, updatedAt: Date())
        let featured = Asset(projectTitle: "Featured First", status: .featured, updatedAt: Date(timeIntervalSinceNow: -3600))
        store.addAsset(archived)
        store.addAsset(featured)

        let snapshot = WidgetSnapshotBuilder.snapshot(from: store)

        XCTAssertEqual(snapshot.topTitles.first, "Featured First")
    }

    func testEmptySnapshotIsZeroed() {
        let snapshot = WidgetSnapshotBuilder.snapshot(from: makeStore())

        XCTAssertEqual(snapshot.totalCount, 0)
        XCTAssertEqual(snapshot.featuredCount, 0)
        XCTAssertEqual(snapshot.reusedCount, 0)
        XCTAssertTrue(snapshot.topTitles.isEmpty)
    }

    func testTopTitlesAreLimitedToThree() {
        let store = makeStore()
        for index in 1...5 {
            store.addAsset(Asset(projectTitle: "Case \(index)"))
        }

        let snapshot = WidgetSnapshotBuilder.snapshot(from: store)

        XCTAssertEqual(snapshot.topTitles.count, 3)
        XCTAssertEqual(snapshot.totalCount, 5)
    }
}
