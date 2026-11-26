//
//  AppIntents.swift
//  ProofDeck
//
//  System / Siri integration. Intents read and write through the shared store.
//  Five intents cover archiving an asset, searching cards, drafting a case
//  summary, reusing a clip and listing featured proofs.
//
//  AI boundary: the summary draft is assembled from fields the user already
//  entered; the on-device model bridge (L2) plugs in behind the same service
//  protocol. No open Q&A or fact recall.
//

import AppIntents
import Foundation

enum ProofDeckIntentError: Error, LocalizedError {
    case invalidID
    case missingEntity

    var errorDescription: String? {
        switch self {
        case .invalidID:    return "The provided identifier is not valid."
        case .missingEntity: return "No matching asset was found."
        }
    }
}

/// Save a new archived asset card.
struct ArchiveAssetIntent: AppIntent {
    static var title: LocalizedStringResource = "Archive a project"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Project title")
    var title: String

    @Parameter(title: "Notes", optional: true)
    var notes: String?

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            let store = PersistenceController.shared.makeStore()
            let asset = Asset(
                projectTitle: title,
                reusableNotes: notes ?? ""
            )
            store.addAsset(asset)
        }
        return .result()
    }
}

/// Search archived cards by keyword (read-only).
struct SearchAssetsIntent: AppIntent {
    static var title: LocalizedStringResource = "Search my archive"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Keyword")
    var keyword: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let text = await MainActor.run { () -> String in
            let store = PersistenceController.shared.makeStore()
            let term = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            let matches = store.assets().filter { AssetSorter.matches($0, term: term) }
            guard !matches.isEmpty else { return "No archived projects match \"\(keyword)\"." }
            let top = matches.prefix(5).map(\.projectTitle)
            return "Found \(matches.count): \(top.joined(separator: ". "))."
        }
        return .result(dialog: IntentDialog(LocalizedStringResource(stringLiteral: text)))
    }
}

/// Draft an editable case-study summary for an asset (read-only draft).
struct ComposeCaseSummaryIntent: AppIntent {
    static var title: LocalizedStringResource = "Draft a case summary"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Asset")
    var asset: AssetEntity

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let id = asset.id
        let draft = try await MainActor.run { () -> String in
            let store = PersistenceController.shared.makeStore()
            guard let asset = store.asset(id: id) else { throw ProofDeckIntentError.missingEntity }
            return CaseSummaryDraft.ruleTemplate(for: asset)
        }
        return .result(dialog: IntentDialog(LocalizedStringResource(stringLiteral: draft)))
    }
}

/// Copy a reusable excerpt from an asset's notes (read-only).
struct ReuseClipIntent: AppIntent {
    static var title: LocalizedStringResource = "Reuse a project note"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Asset")
    var asset: AssetEntity

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let id = asset.id
        let excerpt = try await MainActor.run { () -> String in
            let store = PersistenceController.shared.makeStore()
            guard let asset = store.asset(id: id) else { throw ProofDeckIntentError.missingEntity }
            let clip = ReuseClip(assetID: asset.id, excerpt: asset.reusableNotes, section: .notes)
            store.addClip(clip)
            store.markReused(id: asset.id, at: Date())
            return asset.reusableNotes.isEmpty ? "No reusable notes saved for this project yet." : asset.reusableNotes
        }
        return .result(dialog: IntentDialog(LocalizedStringResource(stringLiteral: excerpt)))
    }
}

/// List featured proofs (read-only).
struct ListFeaturedIntent: AppIntent {
    static var title: LocalizedStringResource = "Show featured proofs"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let text = await MainActor.run { () -> String in
            let store = PersistenceController.shared.makeStore()
            let featured = store.assets().filter { $0.status == .featured }
            guard !featured.isEmpty else { return "You have no featured proofs yet." }
            let top = featured.prefix(5).map(\.projectTitle)
            return "Featured: \(top.joined(separator: ". "))."
        }
        return .result(dialog: IntentDialog(LocalizedStringResource(stringLiteral: text)))
    }
}
