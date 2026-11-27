//
//  AssetDetailView.swift
//  ProofDeck
//
//  Read-only card detail: project context, deliverables, outcomes, testimonial,
//  the L1 case-summary draft (copyable, always an editable draft) and reused
//  clips. Featured toggle, edit and delete live in the toolbar. Nothing here
//  sends or publishes content externally.
//

import SwiftUI
import UIKit

struct AssetDetailView: View {

    @EnvironmentObject var viewModel: StoreViewModel
    let assetID: UUID

    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false
    @State private var copied = false

    private var asset: Asset? { viewModel.asset(id: assetID) }

    private var clips: [ReuseClip] { viewModel.clips(for: assetID) }

    var body: some View {
        Group {
            if let asset {
                content(asset)
            } else {
                ContentUnavailableView(
                    "Project not found",
                    systemImage: "tray",
                    description: Text("This card may have been deleted.")
                )
            }
        }
        .navigationTitle(asset?.projectTitle ?? "Detail")
        .toolbar {
            if let asset {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEdit = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            if let asset {
                AssetEditView(editing: asset)
            }
        }
        .alert("Delete this card?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.delete(id: assetID)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The card and its reused clips are removed from this device. This cannot be undone.")
        }
    }

    @ViewBuilder
    private func content(_ asset: Asset) -> some View {
        List {
            Section("Context") {
                label("Client", asset.clientName)
                label("Role", asset.role)
                label("Industry", asset.industry)
                if !asset.skills.isEmpty {
                    label("Skills", asset.skills.joined(separator: ", "))
                }
            }

            if !asset.deliverables.isEmpty {
                Section("Deliverables") {
                    ForEach(asset.deliverables) { item in
                        VStack(alignment: .leading) {
                            Text(item.title)
                            Text(item.kind.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if !asset.outcomes.isEmpty {
                Section("Outcomes") {
                    ForEach(asset.outcomes) { outcome in
                        VStack(alignment: .leading) {
                            Text(outcome.metric)
                            Text("\(outcome.value)\(outcome.unit ?? "")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if let testimonial = asset.testimonial, !testimonial.quote.isEmpty {
                Section("Feedback") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("“\(testimonial.quote)”")
                        if let source = testimonial.source {
                            Text(source)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Case summary draft") {
                Text(viewModel.summary(for: asset))
                    .font(.subheadline)
                Button {
                    copy(viewModel.summary(for: asset))
                } label: {
                    Label(copied ? "Copied" : "Copy draft",
                          systemImage: copied ? "checkmark" : "doc.on.doc")
                }
            }

            if !clips.isEmpty {
                Section("Reused clips") {
                    ForEach(clips) { clip in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(clip.excerpt)
                            Text(clip.section.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func label(_ title: String, _ value: String?) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value ?? "—")
        }
    }

    private func copy(_ text: String) {
        UIPasteboard.general.string = text
        copied = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            copied = false
        }
    }
}
