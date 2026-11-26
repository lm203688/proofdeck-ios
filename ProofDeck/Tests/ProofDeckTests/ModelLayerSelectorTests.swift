//
//  ModelLayerSelectorTests.swift
//  ProofDeckTests
//
//  Verify the L1/L2 fallback rule: on-device model only on iOS 26+ with an
//  Apple-Intelligence-capable device and an available on-device model; every
//  other combination falls back to the local rule engine.
//

import XCTest
@testable import ProofDeck

final class ModelLayerSelectorTests: XCTestCase {

    private func availability(major: Int,
                              deviceSupportsIntelligence: Bool = true,
                              modelAvailable: Bool = true) -> ModelAvailability {
        ModelAvailability(iosMajorVersion: major,
                          deviceSupportsAppleIntelligence: deviceSupportsIntelligence,
                          onDeviceModelAvailable: modelAvailable)
    }

    func testOlderOSFallsBackToRuleEngine() {
        XCTAssertEqual(ModelLayerSelector.layer(for: availability(major: 17)), .ruleEngine)
        XCTAssertEqual(ModelLayerSelector.layer(for: availability(major: 25)), .ruleEngine)
    }

    func testIOS26WithFullSupportUsesOnDeviceModel() {
        XCTAssertEqual(ModelLayerSelector.layer(for: availability(major: 26)), .onDeviceModel)
        XCTAssertEqual(ModelLayerSelector.layer(for: availability(major: 27)), .onDeviceModel)
    }

    func testUnsupportedDeviceFallsBackToRuleEngine() {
        let availability = ModelAvailability(iosMajorVersion: 26,
                                             deviceSupportsAppleIntelligence: false,
                                             onDeviceModelAvailable: true)
        XCTAssertEqual(ModelLayerSelector.layer(for: availability), .ruleEngine)
    }

    func testUnavailableModelFallsBackToRuleEngine() {
        let availability = ModelAvailability(iosMajorVersion: 26,
                                             deviceSupportsAppleIntelligence: true,
                                             onDeviceModelAvailable: false)
        XCTAssertEqual(ModelLayerSelector.layer(for: availability), .ruleEngine)
    }
}
