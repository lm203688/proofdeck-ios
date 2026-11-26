//
//  CsvExport.swift
//  ProofDeck
//
//  Local-only CSV export. Portable Foundation logic that turns asset cards into
//  spreadsheet-ready text. No network call, account or paywall; CSV destinations
//  stay on device until the user shares the file.
//

import Foundation

enum CsvBuilder {

    static let assetHeader = "Project,Client,Role,Industry,Skills,Deliverables,Outcomes,Testimonial,Reusable notes,Status,Created,Updated,Last reused"

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// CSV rows for every asset in the snapshot.
    static func assetsCSV(_ assets: [Asset]) -> String {
        var lines = [assetHeader]
        for asset in assets {
            let deliverables = asset.deliverables.map(\.title).joined(separator: "; ")
            let outcomes = asset.outcomes.map { "\($0.metric): \($0.value)\($0.unit ?? "")" }.joined(separator: "; ")
            let testimonial = asset.testimonial?.quote ?? ""
            lines.append(row([
                asset.projectTitle,
                asset.clientName,
                asset.role,
                asset.industry,
                asset.skills.joined(separator: "; "),
                deliverables,
                outcomes,
                testimonial,
                asset.reusableNotes,
                asset.status.displayName,
                dateString(asset.createdAt),
                dateString(asset.updatedAt),
                dateString(asset.lastReusedAt)
            ]))
        }
        return lines.joined(separator: "\n")
    }

    private static func row(_ fields: [String?]) -> String {
        fields.map(escape).joined(separator: ",")
    }

    /// RFC 4180 escaping: wrap in double quotes when the field contains a comma,
    /// quote, or line break; double embedded quotes. Empty / nil fields become
    /// an empty column.
    private static func escape(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "" }
        if value.contains(",") || value.contains("\"") ||
            value.contains("\n") || value.contains("\r") {
            return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return value
    }

    private static func dateString(_ date: Date?) -> String? {
        guard let date else { return nil }
        return dateFormatter.string(from: date)
    }
}
