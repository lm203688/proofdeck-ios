//
//  Models.swift
//  ProofDeck
//
//  Plain Codable data models. Persistence is provided behind a store protocol;
//  these types hold the record structure shared across the app, intents and
//  offline tests. They stay free of SwiftData, SwiftUI and network dependencies.
//
//  Domain: archived deliverables, reusable asset cards, case-study summaries and
//  reused clips. Numbers in outcomes are user-entered; the on-device model never
//  invents result figures.
//

import Foundation

/// Whether an asset card is archived or pinned as a featured proof.
enum AssetStatus: String, Codable, CaseIterable, Identifiable {
    case archived
    case featured

    var id: String { rawValue }
}

/// Which part of an asset a reused clip belongs to.
enum ClipSection: String, Codable, CaseIterable {
    case method
    case result
    case quote
    case notes
}

/// Kind of a delivered item.
enum DeliverableKind: String, Codable, CaseIterable {
    case file
    case link
    case image
    case other
}

struct Deliverable: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var kind: DeliverableKind
    var url: String?
    var note: String?

    init(id: UUID = UUID(),
         title: String,
         kind: DeliverableKind = .other,
         url: String? = nil,
         note: String? = nil) {
        self.id = id
        self.title = title
        self.kind = kind
        self.url = url
        self.note = note
    }
}

/// A quantified outcome. `value` is free text so percentages, counts and
/// currency figures stay exactly as the user entered them.
struct Outcome: Identifiable, Codable, Equatable {
    var id: UUID
    var metric: String
    var value: String
    var unit: String?
    var note: String?

    init(id: UUID = UUID(),
         metric: String,
         value: String,
         unit: String? = nil,
         note: String? = nil) {
        self.id = id
        self.metric = metric
        self.value = value
        self.unit = unit
        self.note = note
    }
}

/// A desensitized client testimonial. `shareable` records whether the user may
/// cite it externally; the app does not publish anything itself.
struct Testimonial: Codable, Equatable {
    var quote: String
    var source: String?
    var shareable: Bool

    init(quote: String, source: String? = nil, shareable: Bool = false) {
        self.quote = quote
        self.source = source
        self.shareable = shareable
    }
}

struct MediaLink: Identifiable, Codable, Equatable {
    var id: UUID
    var url: String
    var note: String?

    init(id: UUID = UUID(), url: String, note: String? = nil) {
        self.id = id
        self.url = url
        self.note = note
    }
}

/// An archived deliverable turned into a reusable asset card.
struct Asset: Identifiable, Codable, Equatable {
    var id: UUID
    var projectTitle: String
    var clientName: String?
    var role: String?
    var industry: String?
    var skills: [String]
    var deliverables: [Deliverable]
    var outcomes: [Outcome]
    var testimonial: Testimonial?
    var reusableNotes: String
    var mediaLinks: [MediaLink]
    var status: AssetStatus
    /// Local reference to a FollowDeck deal this card was archived from; only a
    /// UUID link, never a direct connection to another app's private store.
    var sourceDealID: UUID?
    var createdAt: Date
    var updatedAt: Date
    var lastReusedAt: Date?

    init(id: UUID = UUID(),
         projectTitle: String,
         clientName: String? = nil,
         role: String? = nil,
         industry: String? = nil,
         skills: [String] = [],
         deliverables: [Deliverable] = [],
         outcomes: [Outcome] = [],
         testimonial: Testimonial? = nil,
         reusableNotes: String = "",
         mediaLinks: [MediaLink] = [],
         status: AssetStatus = .archived,
         sourceDealID: UUID? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         lastReusedAt: Date? = nil) {
        self.id = id
        self.projectTitle = projectTitle
        self.clientName = clientName
        self.role = role
        self.industry = industry
        self.skills = skills
        self.deliverables = deliverables
        self.outcomes = outcomes
        self.testimonial = testimonial
        self.reusableNotes = reusableNotes
        self.mediaLinks = mediaLinks
        self.status = status
        self.sourceDealID = sourceDealID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastReusedAt = lastReusedAt
    }
}

/// A reusable excerpt copied from an asset card.
struct ReuseClip: Identifiable, Codable, Equatable {
    var id: UUID
    var assetID: UUID
    var excerpt: String
    var section: ClipSection
    var createdAt: Date

    init(id: UUID = UUID(),
         assetID: UUID,
         excerpt: String,
         section: ClipSection = .notes,
         createdAt: Date = Date()) {
        self.id = id
        self.assetID = assetID
        self.excerpt = excerpt
        self.section = section
        self.createdAt = createdAt
    }
}

/// In-app feedback entry (desensitized before leaving the device).
struct FeedbackEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var category: String
    var text: String
    var appVersion: String
    var deviceModel: String
    var createdAt: Date

    init(id: UUID = UUID(),
         category: String,
         text: String,
         appVersion: String,
         deviceModel: String,
         createdAt: Date = Date()) {
        self.id = id
        self.category = category
        self.text = text
        self.appVersion = appVersion
        self.deviceModel = deviceModel
        self.createdAt = createdAt
    }
}
