//
//  ShareViewController.swift
//  ProofDeckShare
//
//  Share-sheet extension: captures shared text and/or a URL and stores it as a
//  pending draft in the shared App Group container. The main app consumes the
//  draft when it next opens. No account, network or remote service is involved.
//

import Social
import UIKit

final class ShareViewController: SLComposeServiceViewController {

    private var pendingText: String?
    private var pendingURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSharedContent()
    }

    override func isContentValid() -> Bool {
        true
    }

    override func configurationItems() -> [Any] {
        []
    }

    override func didSelectPost() {
        let draft = ShareDraftParser.draft(
            text: pendingText ?? contentText,
            url: pendingURL,
            sourceApp: nil
        )
        if let draft {
            ShareDraftStore.save(draft)
        }
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    private func loadSharedContent() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else { return }
        for item in items {
            for provider in item.attachments ?? [] {
                if provider.hasItemConformingToTypeIdentifier("public.url") {
                    provider.loadItem(forTypeIdentifier: "public.url", options: nil) { [weak self] item, _ in
                        self?.pendingURL = item as? URL
                    }
                } else if provider.hasItemConformingToTypeIdentifier("public.text") {
                    provider.loadItem(forTypeIdentifier: "public.text", options: nil) { [weak self] item, _ in
                        self?.pendingText = item as? String
                    }
                }
            }
        }
    }
}
