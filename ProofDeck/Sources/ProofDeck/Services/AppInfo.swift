//
//  AppInfo.swift
//  ProofDeck
//
//  Pure, testable helpers for the Settings / About screen: bundle version
//  presentation and the local-only feedback mailto URL. No store, network or
//  UI state lives here.
//
//  Reused from the shared A-class core (audit 09 §3.1). The feedback recipient
//  is the developer-owned support inbox, shared with the companion app.
//

import Foundation

/// Version and build strings read from the app bundle, prepared for display.
struct AppInfo: Equatable {
    var version: String
    var build: String

    /// Read version / build from a bundle (defaults to the main bundle).
    static func current(bundle: Bundle = .main) -> AppInfo {
        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = bundle.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return AppInfo(version: version, build: build)
    }

    /// "Version 1.0 (3)" style label; build suffix omitted when there is no build.
    var versionDisplay: String {
        let base = "Version \(version)"
        return build.isEmpty ? base : "\(base) (\(build))"
    }
}

/// Builds a `mailto:` URL for the local feedback entry. The mail is composed by
/// the system mail app; the app never sends or uploads this message itself.
enum FeedbackMail {

    /// Developer-owned support inbox for the local feedback mailto entry.
    static let recipient = "463102527@qq.com"

    static func composeURL(to: String, subject: String, body: String) -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = to
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        return components.url
    }
}
