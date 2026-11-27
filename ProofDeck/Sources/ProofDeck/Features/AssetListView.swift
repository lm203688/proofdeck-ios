//
//  AssetListView.swift
//  ProofDeck
//
//  First feature screen: the archived project cards. Search, open a card,
//  create a new one, or share the local CSV snapshot. Empty state when the
//  archive has no matching card yet.
//

import SwiftUI

struct AssetListView: View {

    @ObservedObject var viewModel: StoreViewModel
    @State private var showingNew = false
    @State private var csvURL: URL?

    var body: some View {
        NavigationStack {
            List {
                if viewModel.filteredAssets.isEmpty {
                    ContentUnavailableView(
                        "No archived projects",
                        systemImage: "archivebox",
                        description: Text("Save a completed project as a reusable proof card.")
                    )
                } else {
                    ForEach(viewModel.filteredAssets) { asset in
                        NavigationLink {
                            AssetDetailView(viewModel: viewModel, assetID: asset.id)
                        } label: {
                            AssetRow(asset: asset)
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search archive")
            .navigationTitle("Archive")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let csvURL {
                        ShareLink(item: csvURL, preview: SharePreview("proofdeck-archive.csv")) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNew = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNew) {
                AssetEditView(viewModel: viewModel, editing: nil)
            }
            .onAppear(perform: prepareCSV)
        }
    }

    private func prepareCSV() {
        guard csvURL == nil else { return }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("proofdeck-archive.csv")
        do {
            guard let data = viewModel.csvSnapshot().data(using: .utf8) else { return }
            try data.write(to: url, options: .atomic)
            csvURL = url
        } catch {
            csvURL = nil
        }
    }
}

private struct AssetRow: View {
    let asset: Asset

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(asset.projectTitle)
                    .font(.headline)
                if asset.status == .featured {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }
            let subtitle = [asset.industry, asset.role]
                .compactMap { $0 }
                .joined(separator: " · ")
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if !asset.skills.isEmpty {
                Text(asset.skills.prefix(4).joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
