//
//  CsvExportTests.swift
//  ProofDeckTests
//

import XCTest
@testable import ProofDeck

final class CsvExportTests: XCTestCase {

    func testHeaderAndRowEscaping() {
        let asset = Asset(
            projectTitle: "Consulting, Phase 2",
            clientName: "Acme, Inc.",
            reusableNotes: "Reused the \"module\" layout."
        )

        let csv = CsvBuilder.assetsCSV([asset])
        let lines = csv.components(separatedBy: "\n")
        XCTAssertEqual(lines.first, CsvBuilder.assetHeader)
        // Comma and quote inside a field must be RFC 4180 quoted and doubled.
        XCTAssertTrue(lines[1].contains("\"Consulting, Phase 2\""))
        XCTAssertTrue(lines[1].contains("\"Acme, Inc.\""))
        XCTAssertTrue(lines[1].contains("\"Reused the \"\"module\"\" layout.\""))
    }

    func testEmptyAssetProducesHeaderOnly() {
        let csv = CsvBuilder.assetsCSV([])
        XCTAssertEqual(csv, CsvBuilder.assetHeader)
    }
}
