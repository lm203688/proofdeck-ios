//
//  ClipSorterTests.swift
//  ProofDeckTests
//

import XCTest
@testable import ProofDeck

final class ClipSorterTests: XCTestCase {

    func testClipsSortedNewestFirst() {
        let assetID = UUID()
        let older = ReuseClip(assetID: assetID, excerpt: "Older note",
                              section: .notes, createdAt: Date(timeIntervalSince1970: 1_000_000))
        let newer = ReuseClip(assetID: assetID, excerpt: "Newer note",
                              section: .result, createdAt: Date(timeIntervalSince1970: 2_000_000))

        let sorted = ClipSorter.sorted([older, newer])
        XCTAssertEqual(sorted.map(\.excerpt), ["Newer note", "Older note"])
    }
}
