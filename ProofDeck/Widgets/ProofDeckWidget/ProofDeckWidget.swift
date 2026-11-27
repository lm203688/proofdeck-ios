//
//  ProofDeckWidget.swift
//  ProofDeckWidget
//
//  Glanceable home-screen widget. Reads the summary snapshot written to the shared
//  App Group by the main app; no network access and no direct persistence from
//  the extension.
//

import WidgetKit
import SwiftUI

/// Timeline entry carrying the latest local library summary.
struct ProofDeckEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

/// Provides entries on demand; the app pushes a timeline reload whenever records change.
struct ProofDeckProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProofDeckEntry {
        ProofDeckEntry(date: Date(), snapshot: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (ProofDeckEntry) -> Void) {
        completion(ProofDeckEntry(date: Date(), snapshot: WidgetSnapshotStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProofDeckEntry>) -> Void) {
        let entry = ProofDeckEntry(date: Date(), snapshot: WidgetSnapshotStore.load())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct ProofDeckWidgetEntryView: View {
    let entry: ProofDeckEntry

    private var snapshot: WidgetSnapshot? { entry.snapshot }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Archive")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }

            HStack(spacing: 12) {
                countBox(label: "Saved", value: snapshot?.totalCount ?? 0, color: .blue)
                countBox(label: "Featured", value: snapshot?.featuredCount ?? 0, color: .orange)
                countBox(label: "Reused", value: snapshot?.reusedCount ?? 0, color: .secondary)
            }

            if let titles = snapshot?.topTitles, !titles.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(titles.prefix(2), id: \.self) { title in
                        Text(title)
                            .font(.caption2)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                    }
                }
            } else {
                Text("No archived cards yet.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .widgetURL(URL(string: "proofdeck://archive"))
    }

    private func countBox(label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title2.weight(.bold))
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

@main
struct ProofDeckWidget: Widget {
    private let kind = "ProofDeckWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProofDeckProvider()) { entry in
            ProofDeckWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ProofDeck")
        .description("Your reusable proof archive at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
