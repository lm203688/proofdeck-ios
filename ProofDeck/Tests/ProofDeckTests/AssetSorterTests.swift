//
//  AssetSorterTests.swift
//  ProofDeckTests
//

import XCTest
@testable import ProofDeck

final class AssetSorterTests: XCTestCase {

    private func makeAsset(id: UUID,
                           projectTitle: String,
                           status: AssetStatus,
                           updatedAt: Date,
                           skills: [String] = [],
                           industry: String? = nil) -> Asset {
        Asset(id: id,
              projectTitle: projectTitle,
              industry: industry,
              skills: skills,
              status: status,
              updatedAt: updatedAt)
    }

    func testFeaturedComeFirstThenMostRecentlyUpdated() {
        let older = makeAsset(id: UUID(), projectTitle: "Old", status: .archived,
                              updatedAt: Date(timeIntervalSince1970: 1_000_000))
        let featured = makeAsset(id: UUID(), projectTitle: "Featured", status: .featured,
                                 updatedAt: Date(timeIntervalSince1970: 2_000_000))
        let recent = makeAsset(id: UUID(), projectTitle: "Recent", status: .archived,
                              updatedAt: Date(timeIntervalSince1970: 3_000_000))

        let sorted = AssetSorter.sorted([older, recent, featured])
        XCTAssertEqual(sorted.map(\.title), ["Featured", "Recent", "Old"])
    }

    func testMatchesTitleIndustrySkillsCaseInsensitive() {
        let asset = makeAsset(id: UUID(), projectTitle: "Brand Refresh", status: .archived,
                              updatedAt: Date(), skills: ["Branding", "Web Design"],
                              industry: "Retail")

        XCTAssertTrue(AssetSorter.matches(asset, term: "brand"))
        XCTAssertTrue(AssetSorter.matches(asset, term: "branding"))
        XCTAssertTrue(AssetSorter.matches(asset, term: "retail"))
        XCTAssertFalse(AssetSorter.matches(asset, term: "plumbing"))
    }
}
