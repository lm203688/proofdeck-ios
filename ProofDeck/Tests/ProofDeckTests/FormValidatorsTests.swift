//
//  FormValidatorsTests.swift
//  ProofDeckTests
//

import XCTest
@testable import ProofDeck

final class FormValidatorsTests: XCTestCase {

    func testNormalizedTagsTrimsDropsEmitsAndDeduplicates() {
        XCTAssertEqual(
            FormValidators.normalizedTags(" Swift , design, swift, ,"),
            ["Swift", "design"]
        )
    }

    func testValidEmailPassesAndInvalidFails() {
        XCTAssertTrue(FormValidators.isValidEmail(nil))
        XCTAssertTrue(FormValidators.isValidEmail(""))
        XCTAssertTrue(FormValidators.isValidEmail("dev@example.com"))
        XCTAssertFalse(FormValidators.isValidEmail("dev@example"))
        XCTAssertFalse(FormValidators.isValidEmail("dev@.com"))
    }

    func testRequiredTextTrimsBlankToNil() {
        XCTAssertNil(FormValidators.requiredText("   "))
        XCTAssertNil(FormValidators.requiredText(nil))
        XCTAssertEqual(FormValidators.requiredText("  work "), "work")
    }
}
