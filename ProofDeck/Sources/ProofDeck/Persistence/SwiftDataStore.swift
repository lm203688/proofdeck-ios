//
//  SwiftDataStore.swift
//  ProofDeck
//
//  SwiftData-backed StoreProtocol implementation. The domain structs in
//  Models.swift stay pure and portable; this layer maps between them and
//  SwiftData @Model records. Nested Codable arrays are stored as JSON Data so
//  the record stays flat without a relation graph. Local-first; no CloudKit
//  or sync is enabled here.
//

import Foundation
import SwiftData

// MARK: - SwiftData records

@Model final class SDAsset {
    @Attribute(.unique) var id: UUID
    var projectTitle: String
    var clientName: String?
    var role: String?
    var industry: String?
    var skills: [String]
    var deliverablesData: Data
    var outcomesData: Data
    var testimonialData: Data?
    var reusableNotes: String
    var mediaLinksData: Data
    var statusRaw: String
    var sourceDealID: UUID?
    var createdAt: Date
    var updatedAt: Date
    var lastReusedAt: Date?

    init(id: UUID, projectTitle: String, clientName: String?, role: String?, industry: String?,
         skills: [String], deliverablesData: Data, outcomesData: Data, testimonialData: Data?,
         reusableNotes: String, mediaLinksData: Data, statusRaw: String, sourceDealID: UUID?,
         createdAt: Date, updatedAt: Date, lastReusedAt: Date?) {
        self.id = id
        self.projectTitle = projectTitle
        self.clientName = clientName
        self.role = role
        self.industry = industry
        self.skills = skills
        self.deliverablesData = deliverablesData
        self.outcomesData = outcomesData
        self.testimonialData = testimonialData
        self.reusableNotes = reusableNotes
        self.mediaLinksData = mediaLinksData
        self.statusRaw = statusRaw
        self.sourceDealID = sourceDealID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastReusedAt = lastReusedAt
    }
}

@Model final class SDClip {
    @Attribute(.unique) var id: UUID
    var assetID: UUID
    var excerpt: String
    var sectionRaw: String
    var createdAt: Date

    init(id: UUID, assetID: UUID, excerpt: String, sectionRaw: String, createdAt: Date) {
        self.id = id
        self.assetID = assetID
        self.excerpt = excerpt
        self.sectionRaw = sectionRaw
        self.createdAt = createdAt
    }
}

// MARK: - JSON coding helpers

private enum RecordCoding {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static func encode<T: Codable>(_ value: T) -> Data {
        (try? encoder.encode(value)) ?? Data()
    }

    static func decode<T: Codable>(_ type: T.Type, from data: Data) -> T? {
        try? decoder.decode(type, from: data)
    }
}

// MARK: - Mapping

private extension SDAsset {
    func toAsset() -> Asset {
        Asset(
            id: id,
            projectTitle: projectTitle,
            clientName: clientName,
            role: role,
            industry: industry,
            skills: skills,
            deliverables: RecordCoding.decode([Deliverable].self, from: deliverablesData) ?? [],
            outcomes: RecordCoding.decode([Outcome].self, from: outcomesData) ?? [],
            testimonial: testimonialData.flatMap { RecordCoding.decode(Testimonial.self, from: $0) },
            reusableNotes: reusableNotes,
            mediaLinks: RecordCoding.decode([MediaLink].self, from: mediaLinksData) ?? [],
            status: AssetStatus(rawValue: statusRaw) ?? .archived,
            sourceDealID: sourceDealID,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastReusedAt: lastReusedAt
        )
    }
}

private extension Asset {
    func toSD() -> SDAsset {
        SDAsset(
            id: id,
            projectTitle: projectTitle,
            clientName: clientName,
            role: role,
            industry: industry,
            skills: skills,
            deliverablesData: RecordCoding.encode(deliverables),
            outcomesData: RecordCoding.encode(outcomes),
            testimonialData: testimonial.map { RecordCoding.encode($0) },
            reusableNotes: reusableNotes,
            mediaLinksData: RecordCoding.encode(mediaLinks),
            statusRaw: status.rawValue,
            sourceDealID: sourceDealID,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastReusedAt: lastReusedAt
        )
    }
}

private extension SDClip {
    func toClip() -> ReuseClip {
        ReuseClip(
            id: id,
            assetID: assetID,
            excerpt: excerpt,
            section: ClipSection(rawValue: sectionRaw) ?? .notes,
            createdAt: createdAt
        )
    }
}

private extension ReuseClip {
    func toSD() -> SDClip {
        SDClip(id: id, assetID: assetID, excerpt: excerpt, sectionRaw: section.rawValue, createdAt: createdAt)
    }
}

// MARK: - Store implementation

final class SwiftDataStore: StoreProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    private func fetch<T: PersistentModel>(_ type: T.Type) -> [T] {
        (try? context.fetch(FetchDescriptor<T>())) ?? []
    }

    func assets() -> [Asset] {
        fetch(SDAsset.self).map { $0.toAsset() }
    }

    func asset(id: UUID) -> Asset? {
        fetch(SDAsset.self).first { $0.id == id }?.toAsset()
    }

    func addAsset(_ asset: Asset) {
        context.insert(asset.toSD())
    }

    func updateAsset(_ asset: Asset) {
        guard let record = fetch(SDAsset.self).first(where: { $0.id == asset.id }) else { return }
        record.projectTitle = asset.projectTitle
        record.clientName = asset.clientName
        record.role = asset.role
        record.industry = asset.industry
        record.skills = asset.skills
        record.deliverablesData = RecordCoding.encode(asset.deliverables)
        record.outcomesData = RecordCoding.encode(asset.outcomes)
        record.testimonialData = asset.testimonial.map { RecordCoding.encode($0) }
        record.reusableNotes = asset.reusableNotes
        record.mediaLinksData = RecordCoding.encode(asset.mediaLinks)
        record.statusRaw = asset.status.rawValue
        record.sourceDealID = asset.sourceDealID
        record.updatedAt = asset.updatedAt
        record.lastReusedAt = asset.lastReusedAt
    }

    func deleteAsset(id: UUID) {
        guard let record = fetch(SDAsset.self).first(where: { $0.id == id }) else { return }
        context.delete(record)
        fetch(SDClip.self).filter { $0.assetID == id }.forEach { context.delete($0) }
    }

    func clips(for assetID: UUID) -> [ReuseClip] {
        fetch(SDClip.self).filter { $0.assetID == assetID }.map { $0.toClip() }
    }

    func addClip(_ clip: ReuseClip) {
        context.insert(clip.toSD())
    }

    func markReused(id: UUID, at date: Date) {
        guard let record = fetch(SDAsset.self).first(where: { $0.id == id }) else { return }
        record.lastReusedAt = date
    }
}
