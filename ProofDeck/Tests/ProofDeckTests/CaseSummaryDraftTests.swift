//
//  CaseSummaryDraftTests.swift
//  ProofDeckTests
//

import XCTest
@testable import ProofDeck

final class CaseSummaryDraftTests: XCTestCase {

    func testTemplateIncludesEnteredOutcomeAndDeliverable() {
        let asset = Asset(
            projectTitle: "Store Redesign",
            role: "Lead Designer",
            industry: "Retail",
            deliverables: [Deliverable(title: "Homepage mockups", kind: .file)],
            outcomes: [Outcome(metric: "Conversion", value: "18", unit: "%")],
            reusableNotes: "Reused the modular card system."
        )

        let draft = CaseSummaryDraft.ruleTemplate(for: asset)
        XCTAssertTrue(draft.contains("Lead Designer"))
        XCTAssertTrue(draft.contains("Homepage mockups"))
        XCTAssertTrue(draft.contains("Conversion: 18%"))
        XCTAssertTrue(draft.contains("Background:"))
        XCTAssertTrue(draft.contains("Result:"))
    }

    func testMissingOutcomeFallsBackToPlaceholder() {
        let asset = Asset(projectTitle: "Consulting engagement")
        let draft = CaseSummaryDraft.ruleTemplate(for: asset)
        XCTAssertTrue(draft.contains("[add the quantified outcome.]"))
    }
}
