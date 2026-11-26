//
//  FormValidators.swift
//  ProofDeck
//
//  Pure, testable input validation for the create/edit forms. These helpers
//  only normalize and check strings; they hold no store, UI or network state.
//  Optional fields treat an empty value as valid; a filled-in value must meet
//  the format rule before the form allows saving.
//
//  Reused from the shared A-class core (audit 09 §3.1).
//

import Foundation

enum FormValidators {

    /// Trimmed whitespace around an optional string; nil when empty.
    static func trimmedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }

    /// Email format check. Empty / nil is valid because email is optional.
    static func isValidEmail(_ email: String?) -> Bool {
        guard let email = trimmedOptional(email) else { return true }

        let atParts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard atParts.count == 2 else { return false }
        let local = String(atParts[0])
        let domain = String(atParts[1])

        guard !local.isEmpty, !domain.isEmpty else { return false }
        guard !local.contains(" "), !domain.contains(" ") else { return false }

        let labels = domain.split(separator: ".", omittingEmptySubsequences: false)
        guard labels.count >= 2 else { return false }
        guard labels.allSatisfy({ !$0.isEmpty }) else { return false }
        let tld = labels.last!
        guard tld.count >= 2, tld.allSatisfy({ $0.isLetter }) else { return false }

        guard !local.hasPrefix("."), !local.hasSuffix(".") else { return false }
        return true
    }

    /// Normalize comma-separated tag text: trim, drop empties, de-duplicate
    /// while preserving first-seen order.
    static func normalizedTags(_ text: String) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for part in text.split(separator: ",") {
            let tag = part.trimmingCharacters(in: .whitespaces)
            guard !tag.isEmpty, !seen.contains(tag) else { continue }
            seen.insert(tag)
            result.append(tag)
        }
        return result
    }

    /// Trimmed non-empty required text; nil when blank.
    static func requiredText(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
