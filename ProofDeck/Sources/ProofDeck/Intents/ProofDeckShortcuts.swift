//
//  ProofDeckShortcuts.swift
//  ProofDeck
//
//  Expose the app's intents as Siri and Shortcuts home-screen suggestions. Entity
//  parameters resolve through the AppEntity queries in Entities.swift. AppShortcuts
//  are available on iOS 16.0+; the deployment target is iOS 17.0, so no version gate
//  is required here.
//

import AppIntents

struct ProofDeckShortcuts: AppShortcutsProvider {

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ArchiveAssetIntent(),
            phrases: ["Archive a project in \(.applicationName)"],
            shortTitle: "Archive project",
            systemImageName: "archivebox"
        )
        AppShortcut(
            intent: SearchAssetsIntent(),
            phrases: ["Search my archive in \(.applicationName)"],
            shortTitle: "Search archive",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: ComposeCaseSummaryIntent(),
            phrases: ["Draft a case summary in \(.applicationName)"],
            shortTitle: "Case summary",
            systemImageName: "sparkles"
        )
        AppShortcut(
            intent: ReuseClipIntent(),
            phrases: ["Reuse a project note in \(.applicationName)"],
            shortTitle: "Reuse note",
            systemImageName: "doc.on.doc"
        )
        AppShortcut(
            intent: ListFeaturedIntent(),
            phrases: ["Show featured proofs in \(.applicationName)"],
            shortTitle: "Featured proofs",
            systemImageName: "star"
        )
    }
}
