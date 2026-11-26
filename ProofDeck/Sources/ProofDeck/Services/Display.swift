//
//  Display.swift
//  ProofDeck
//
//  Shared read-only formatting helpers for screens. No business logic here;
//  maps model raw values to human-readable English labels and short dates.
//

import Foundation

extension AssetStatus {
    var displayName: String {
        switch self {
        case .archived:  return "Archived"
        case .featured:  return "Featured"
        }
    }
}

extension ClipSection {
    var displayName: String {
        switch self {
        case .method:  return "Method"
        case .result:  return "Result"
        case .quote:   return "Quote"
        case .notes:   return "Notes"
        }
    }
}

extension DeliverableKind {
    var displayName: String {
        switch self {
        case .file:   return "File"
        case .link:   return "Link"
        case .image:  return "Image"
        case .other:  return "Other"
        }
    }
}

enum DisplayFormat {
    static let shortDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    static let shortDateTime: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    static func date(_ date: Date) -> String { shortDate.string(from: date) }
    static func dateTime(_ date: Date) -> String { shortDateTime.string(from: date) }
}
