//
//  CaseSummaryDraft.swift
//  ProofDeck
//
//  L1 rule-engine case-summary draft. Assembles an editable background → problem
//  → approach → result outline from fields the user already entered. The L2
//  on-device model bridge will plug in behind the same draft service later;
//  every result stays an editable draft the user reviews before use.
//
//  Pure Foundation logic; testable off-device without a model or store.
//

import Foundation

enum CaseSummaryDraft {

    /// Build the L1 template draft for an asset. Missing fields fall back to
    /// neutral placeholders rather than invented facts or figures.
    static func ruleTemplate(for asset: Asset) -> String {
        let role = asset.role ?? "Contributor"
        let industry = asset.industry ?? "the client's field"
        let deliverables = asset.deliverables.map(\.title).joined(separator: ", ")
        let outcomes = asset.outcomes.map { "\($0.metric): \($0.value)\($0.unit ?? "")" }.joined(separator: "; ")
        let testimonial = asset.testimonial?.quote ?? ""

        var lines: [String] = []
        lines.append("Background: \(role) on a \(industry) project titled \"\(asset.projectTitle)\".")
        lines.append("Problem: [describe the starting constraint or brief.]")
        lines.append("Approach: delivered \(deliverables.isEmpty ? "the project scope" : deliverables).")
        if !outcomes.isEmpty {
            lines.append("Result: \(outcomes).")
        } else {
            lines.append("Result: [add the quantified outcome.]")
        }
        if !testimonial.isEmpty {
            lines.append("Feedback: \"\(testimonial)\"")
        }
        return lines.joined(separator: "\n")
    }
}
