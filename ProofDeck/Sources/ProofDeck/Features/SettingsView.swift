//
//  SettingsView.swift
//  ProofDeck
//
//  About, privacy summary and the local-only feedback mailto draft. The feedback
//  message is composed by the system mail app; the app never sends or uploads it.
//

import SwiftUI
import UIKit

struct SettingsView: View {

    private let info = AppInfo.current()

    private var feedbackURL: URL? {
        let device = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let body = "Device: \(device)\nApp: \(info.versionDisplay)\n\n"
        return FeedbackMail.composeURL(
            to: FeedbackMail.recipient,
            subject: "ProofDeck feedback",
            body: body
        )
    }

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
                    if let url = feedbackURL {
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
