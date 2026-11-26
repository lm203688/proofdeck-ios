//
//  Entities.swift
//  ProofDeck
//
//  AppEntity representation of the local asset cards, so Siri and Shortcuts can
//  pick a real card instead of entering a raw UUID. Queries read through the
//  shared MainActor store.
//

import AppIntents
import Foundation

struct AssetEntity: AppEntity {
    let id: UUID
    let title: String
    let status: AssetStatus
    let industry: String?

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Asset"
    static var defaultQuery = AssetEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: title),
            subtitle: industry.map { LocalizedStringResource(stringLiteral: "\($0) · \(status.displayName)") }
                ?? LocalizedStringResource(stringLiteral: status.displayName)
        )
    }

    init(id: UUID, title: String, status: AssetStatus, industry: String?) {
        self.id = id
        self.title = title
        self.status = status
        self.industry = industry
    }

    init(_ asset: Asset) {
        self.init(id: asset.id, title: asset.projectTitle, status: asset.status, industry: asset.industry)
    }
}

struct AssetEntityQuery: EntityQuery, EntityStringQuery {
    func entities(for identifiers: [UUID]) async throws -> [AssetEntity] {
        await MainActor.run {
            let store = PersistenceController.shared.makeStore()
            let wanted = Set(identifiers)
            return store.assets().filter { wanted.contains($0.id) }.map(AssetEntity.init)
        }
    }

    func suggestedEntities() async throws -> [AssetEntity] {
        await MainActor.run {
            PersistenceController.shared.makeStore().assets().map(AssetEntity.init)
        }
    }

    func entities(matching string: String) async throws -> [AssetEntity] {
        await MainActor.run {
            let store = PersistenceController.shared.makeStore()
            let term = string.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !term.isEmpty else { return store.assets().map(AssetEntity.init) }
            return store.assets().filter { AssetSorter.matches($0, term: term) }.map(AssetEntity.init)
        }
    }
}
