//
//  AppInfoTests.swift
//  ProofDeckTests
//
//  Verify version presentation and the local-only feedback mailto URL builder.
//

import XCTest
@testable import ProofDeck

final class AppInfoTests: XCTestCase {

    func testVersionDisplayIncludesBuildWhenPresent() {
        let info = AppInfo(version: "1.0", build: "1")
        XCTAssertEqual(info.versionDisplay, "Version 1.0 (1)")
    }

    func testVersionDisplayOmitsEmptyBuild() {
        let info = AppInfo(version: "1.0", build: "")
        XCTAssertEqual(info.versionDisplay, "Version 1.0")
    }

    func testFeedbackMailURLTargetsRecipientWithSubjectAndBody() throws {
        let url = try XCTUnwrap(
            FeedbackMail.composeURL(
                to: FeedbackMail.recipient,
                subject: "ProofDeck feedback",
                body: "Device: iOS 18\nApp: Version 1.0 (1)"
            )
        )
        XCTAssertEqual(url.scheme, "mailto")
        XCTAssertEqual(url.path, FeedbackMail.recipient)

        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let subject = components.queryItems?.first(where: { $0.name == "subject" })?.value
        let body = components.queryItems?.first(where: { $0.name == "body" })?.value
        XCTAssertEqual(subject, "ProofDeck feedback")
        XCTAssertEqual(body, "Device: iOS 18\nApp: Version 1.0 (1)")
    }
}
