//
//  ShareDraft.swift
//  ProofDeckShared
//
//  Cross-target draft handed from the Share Extension to the main app through
//  the shared App Group container. Pure Foundation so it compiles into the app,
//  the extension and the offline tests. Nothing leaves the device.
//

import Foundation

/// A pre-filled draft captured from a share sheet: text and/or a link from
/// another app. The main app turns this into a new asset card on first open.
struct ShareDraft: Codable, Equatable, Identifiable {
    var id: UUID
    var title: String
    var body: String
    var link: String?
    var sourceApp: String?
    var createdAt: Date
}

enum ShareDraftStore {
    /// Must match the `com.apple.security.application-groups` entitlement on both targets.
    static let suiteName = "group.com.lixing.proofdeck"
    private static let key = "proofdeck.share-draft"

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    static func save(_ draft: ShareDraft) {
        guard let data = try? encoder.encode(draft) else { return }
        UserDefaults(suiteName: suiteName)?.set(data, forKey: key)
    }

    /// Reads the pending draft and clears it so it is only consumed once.
    static func loadAndClear() -> ShareDraft? {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: key),
              let draft = try? decoder.decode(ShareDraft.self, from: data) else {
            return nil
        }
        defaults.removeObject(forKey: key)
        return draft
    }
}

/// Turns raw share-sheet content (text and/or a URL) into a draft. Pure
/// function: no extension context, no UserDefaults, so it is testable offline.
enum ShareDraftParser {

    static func draft(text: String?, url: URL?, sourceApp: String?) -> ShareDraft? {
        let trimmedText = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let link = url?.absoluteString
        guard !trimmedText.isEmpty || link != nil else { return nil }

        let lines = trimmedText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        let nonEmpty = lines.filter { !$0.isEmpty }

        let title: String
        let body: String
        if nonEmpty.isEmpty {
            title = url?.host ?? "Shared link"
            body = ""
        } else {
            title = nonEmpty[0]
            body = nonEmpty.dropFirst().joined(separator: "\n")
        }

        return ShareDraft(
            id: UUID(),
            title: title,
            body: body,
            link: link,
            sourceApp: sourceApp,
            createdAt: Date()
        )
    }
}
