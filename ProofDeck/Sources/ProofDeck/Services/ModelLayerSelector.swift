//
//  ModelLayerSelector.swift
//  ProofDeck
//
//  Pure, portable selection of the AI backing layer for the current device/OS.
//  No Foundation Models import lives here: the framework is gated to iOS 26.0+
//  and Apple-Intelligence-capable devices. This selector only reasons about
//  injected availability flags so the fallback path can be tested off-device.
//
//  Reused unchanged from the shared A-class core (audit 09 §3.1).
//

import Foundation

/// The AI backing layer that can serve a request.
enum ModelLayer: String {
    /// L1: local rule engine (shipped MVP).
    case ruleEngine
    /// L2: on-device Apple Foundation Model (planned).
    case onDeviceModel
}

/// Injectable availability inputs for the layer selector.
struct ModelAvailability {
    /// iOS major version on the running device.
    let iosMajorVersion: Int
    /// Whether the device supports Apple Intelligence at all.
    let deviceSupportsAppleIntelligence: Bool
    /// Whether the on-device Foundation Model is actually available to this app.
    let onDeviceModelAvailable: Bool
}

enum ModelLayerSelector {
    /// L2 requires iOS 26.0+ AND an Apple-Intelligence-capable device with the
    /// on-device model available; anything else falls back to the L1 rule engine.
    static func layer(for availability: ModelAvailability) -> ModelLayer {
        guard availability.iosMajorVersion >= 26,
              availability.deviceSupportsAppleIntelligence,
              availability.onDeviceModelAvailable else {
            return .ruleEngine
        }
        return .onDeviceModel
    }
}
