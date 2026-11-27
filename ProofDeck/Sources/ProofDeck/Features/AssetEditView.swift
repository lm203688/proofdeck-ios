//
//  AssetEditView.swift
//  ProofDeck
//
//  Create or edit an asset card. The title is required; client, role, industry
//  and notes are optional. Skills are entered as comma-separated tags and
//  normalized through the shared validator. Deliverables, outcomes and the
//  testimonial are edited in a later iteration; this screen preserves the
//  existing values when editing.
//

import SwiftUI

struct AssetEditView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: StoreViewModel
    let editing: Asset?

    @State private var title: String
    @State private var clientName: String
    @State private var role: String
    @State private var industry: String
    @State private var skillsText: String
    @State private var reusableNotes: String
    @State private var featured: Bool

    init(editing: Asset? = nil) {
        self.editing = editing
        _title = State(initialValue: editing?.projectTitle ?? "")
        _clientName = State(initialValue: editing?.clientName ?? "")
        _role = State(initialValue: editing?.role ?? "")
        _industry = State(initialValue: editing?.industry ?? "")
        _skillsText = State(initialValue: editing?.skills.joined(separator: ", ") ?? "")
        _reusableNotes = State(initialValue: editing?.reusableNotes ?? "")
        _featured = State(initialValue: editing?.status == .featured)
    }

    private var canSave: Bool {
        FormValidators.requiredText(title) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Project") {
                    TextField("Title", text: $title)
                    TextField("Client", text: $clientName)
                    TextField("Role", text: $role)
                    TextField("Industry", text: $industry)
                }
                Section("Tags") {
                    TextField("Skills (comma separated)", text: $skillsText)
                }
                Section("Reusable notes") {
                    TextEditor(text: $reusableNotes)
                        .frame(minHeight: 120)
                }
                Toggle("Featured proof", isOn: $featured)
            }
            .navigationTitle(editing == nil ? "New project" : "Edit project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        let base = editing ?? Asset(projectTitle: "")
        let asset = Asset(
            id: base.id,
            projectTitle: FormValidators.requiredText(title) ?? "",
            clientName: FormValidators.trimmedOptional(clientName),
            role: FormValidators.trimmedOptional(role),
            industry: FormValidators.trimmedOptional(industry),
            skills: FormValidators.normalizedTags(skillsText),
            deliverables: base.deliverables,
            outcomes: base.outcomes,
            testimonial: base.testimonial,
            reusableNotes: reusableNotes.trimmingCharacters(in: .whitespacesAndNewlines),
            mediaLinks: base.mediaLinks,
            status: featured ? .featured : .archived,
            sourceDealID: base.sourceDealID,
            createdAt: base.createdAt,
            updatedAt: Date(),
            lastReusedAt: base.lastReusedAt
        )
        viewModel.save(asset)
        dismiss()
    }
}
