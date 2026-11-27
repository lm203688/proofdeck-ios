//
//  SettingsView.swift
//  ProofDeck
//
//  About, privacy summary and the local-only feedback mailto draft. The feedback
//  message is composed by the system mail app; the app never sends or uploads it.
//  The recipient is a placeholder until the developer support inbox is set.
//

import SwiftUI

struct SettingsView: View {

    private let info = AppInfo.current()

    var body: some View {
        NavigationStack {
            List {
                Section("About") {
                    LabeledContent("Version", value: info.versionDisplay)
                    Text("FollowDeck family: archive completed deliverables as reusable proof cards.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Privacy") {
                    Text("All records stay on this device. No account, analytics or data collection. Export and delete stay on device.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Feedback") {
                    if let url = FeedbackMail.composeURL(
                        to: FeedbackMail.recipient,
                        subject: "ProofDeck feedback",
                        body: ""
                    ) {
                        Link(destination: url) {
                            Label("Send feedback", systemImage: "envelope")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
