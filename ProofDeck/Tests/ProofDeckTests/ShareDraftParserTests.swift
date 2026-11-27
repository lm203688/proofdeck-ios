//
//  ShareDraftParserTests.swift
//  ProofDeckTests
//
//  Verify the share-sheet content parser and the one-shot draft store without
//  touching the extension context, the share sheet or any on-device container.
//

import XCTest
@testable import ProofDeck

final class ShareDraftParserTests: XCTestCase {

    func testPlainTextSplitsFirstLineIntoTitle() {
        let draft = ShareDraftParser.draft(
            text: "Project Title\nSecond line\nThird line",
            url: nil,
            sourceApp: nil
        )

        XCTAssertEqual(draft?.title, "Project Title")
        XCTAssertEqual(draft?.body, "Second line\nThird line")
        XCTAssertNil(draft?.link)
    }

    func testURLOnlyDraftUsesHostAsTitle() {
        let url = URL(string: "https://example.com/article")
        let draft = ShareDraftParser.draft(text: nil, url: url, sourceApp: nil)

        XCTAssertEqual(draft?.link, "https://example.com/article")
        XCTAssertEqual(draft?.title, "example.com")
        XCTAssertEqual(draft?.body, "")
    }

    func testTextAndURLAreCombined() {
        let url = URL(string: "https://example.com/ref")
        let draft = ShareDraftParser.draft(text: "Case note", url: url, sourceApp: "Safari")

        XCTAssertEqual(draft?.title, "Case note")
        XCTAssertEqual(draft?.link, "https://example.com/ref")
        XCTAssertEqual(draft?.sourceApp, "Safari")
    }

    func testEmptyContentReturnsNil() {
        XCTAssertNil(ShareDraftParser.draft(text: "   ", url: nil, sourceApp: nil))
        XCTAssertNil(ShareDraftParser.draft(text: nil, url: nil, sourceApp: nil))
    }

    func testDraftStoreRoundTripIsConsumedOnce() {
        let draft = ShareDraft(
            id: UUID(),
            title: "Shared case",
            body: "Body",
            link: "https://example.com",
            sourceApp: nil,
            createdAt: Date()
        )

        ShareDraftStore.save(draft)
        let loaded = ShareDraftStore.loadAndClear()

        XCTAssertEqual(loaded?.title, "Shared case")
        XCTAssertEqual(loaded?.body, "Body")
        XCTAssertEqual(loaded?.link, "https://example.com")
        XCTAssertNil(ShareDraftStore.loadAndClear())
    }
}
