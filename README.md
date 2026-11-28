# ProofDeck — Deliverable Archive & Reusable Proof Cards

> Second Apple-ecosystem app in the FollowDeck family. FollowDeck tracks active
> clients and deals; ProofDeck archives completed deliverables as reusable asset
> cards and editable case summaries. Local-first, English-only, individual account.

## Locked constraints

- **Platform:** Apple only (iPhone / iPad, Mac if needed). No Android, no web at launch.
- **OS / devices:** Target current and recently released Apple devices and OS
  versions; adapt to new screens and platform features, keep backward compatibility
  with supported older devices and OS releases. New features gate on iOS 26; minimum
  deployment target is iOS 17.0.
- **Language:** English only — UI, store metadata, marketing and support copy.
- **Regions:** All overseas App Store regions allowed; **mainland China (CHN) excluded**.
- **Privacy:** Local-first; start from `No Data Collected`. Feedback goes through a
  system mailto draft only; data is exportable and deletable.
- **AI:** Prefer native platform AI (Apple Intelligence / Siri / App Intents);
  third-party or in-house API key is the fallback. Keys are never hard-coded or
  committed. On-device model only transforms text the user already has (summarize /
  rewrite / tag / classify / extract); no open Q&A, fact recall or multi-step reasoning.
- **Account:** Individual Apple Developer account; non-sensitive category (no medical
  diagnosis, financial advice, legal opinion, payment acquiring).

## Domain and MVP closed loop

1. **Archive** completed deliverables by client/project; import from a FollowDeck deal
   via system deep link / share (local UUID reference only), or create standalone.
2. **Asset card:** deliverables, quantified outcomes, desensitized testimonial,
   reusable notes, media links; tags + full-text search.
3. **Case summary:** editable background → problem → approach → result draft. L1 rule
   template ships in MVP; L2 on-device model bridge plugs in behind the same protocol.
4. **Reuse:** search by industry/skill/outcome; copy notes or reusable clips.
5. **Export / delete:** local JSON/CSV export, deletable; client identity desensitization.

Out of MVP: online portfolio site / social distribution, proposal/contract generation,
payments/invoices/tax, team seats, built-in product sales, open Q&A.

## Directory layout

```
.
├── project.yml                         # XcodeGen spec (generated .xcodeproj is not committed)
├── .github/workflows/ci.yml            # validate + macOS compile/test lane (no signing)
├── .gitignore
└── ProofDeck/
    ├── Sources/ProofDeck/
    │   ├── App/ProofDeckApp.swift      # @main composition root
    │   ├── Models/Models.swift         # plain Codable domain models
    │   ├── Persistence/PersistenceController.swift  # store protocol + SwiftData container
    │   ├── Persistence/SwiftDataStore.swift         # @Model records + SwiftData-backed store
    │   ├── Services/                    # A-class core + domain services
    │   ├── Intents/                     # AppIntents, AppEntity, shortcuts provider
    │   ├── Assets.xcassets/
    │   ├── Info.plist
    │   ├── PrivacyInfo.xcprivacy        # privacy manifest (UserDefaults App Group reason)
    │   └── ProofDeck.entitlements
    ├── Shared/WidgetSnapshot.swift     # cross-target snapshot model + App Group store
    ├── Shared/ShareDraft.swift         # share draft model + one-shot App Group store + parser
    ├── Widgets/ProofDeckWidget/        # WidgetKit extension embedded in the app (+ privacy manifest)
    ├── Extensions/ProofDeckShare/      # share-services extension embedded in the app (+ privacy manifest)
    └── Tests/ProofDeckTests/           # offline unit tests (stubbed, no network/model)
```

## Shared-core reuse map (audit 09 §3.1)

- **A-class, copy unchanged:** `ModelLayerSelector`, `FormValidators`, `AppInfo`
  (recipient replaced), `Sorters`, `CsvExport`, `Display`.
- **B-class, parameterize:** subscription manager/service, entitlement, paywall plan and
  presentation, product IDs. Strip product IDs and inject the product set; StoreKit is
  intentionally left empty until the ASC record exists.
- **C-class, generalize or rebuild:** Spotlight / reminder / deep-link / widget
  snapshot, on-device model bridge and draft generator, domain models and feature
  views. The SwiftData container and store are now wired in behind the store protocol.

## CI lanes

- **`compile`** (default, every push): ubuntu validate (required paths, secret scan,
  YAML check) → `xcode-27` runner selects the newest Xcode ≥ iOS 27 SDK, installs
  XcodeGen, generates the project, picks the newest available iPhone simulator, builds
  Debug and runs unit tests. No signing secrets required.
- **`dry_run`** (Route B signing): secrets already provisioned in the repo; the lane
  imports the `.p12` into a throwaway keychain, installs the main / widget / share
  profiles, archives Manual, exports the App Store IPA, verifies SDK / build number /
  icon, then uploads to TestFlight. Dry-run builds use a CI-only build number segment
  so they never collide with release builds.
- **`release`**: same signing/archive/export path; the App Store submit stays gated
  behind a manual `release` dispatch until listing materials are assembled in ASC.
- `inspect` / `prepare`: copied from the FollowDeck ci.yml once the TestFlight and
  listing materials are assembled in ASC.

## Pre-release items still to fill

- Placeholder 1024×1024 opaque (24bpp RGB, no alpha) icon in `AppIcon.appiconset`; the final brand icon replaces it once the name is locked.
- ASC App record created (App ID 6840349401, iOS + visionOS). Still to fill in ASC:
  privacy questionnaire (No Data Collected starting point), age rating, territory
  availability excluding CHN.
- Route B signing material: distribution `.p12` + App Store profiles, kept as CI
  secrets only.
- Spotlight indexing, the widget snapshot, the SwiftData-backed local store and the
  Share Extension (shared text/URL into a pre-filled draft) are already wired.
- Brand name public coarse check: trademark class 9/42 proximity + domain availability
  (non-legal opinion). The store record name is `ArchiveDeck`; `ProofDeck` was already
  taken on the App Store, and fallbacks `ArchivDeck` / `DoneDeck` / `PortDeck` checked
  free. CaseFolio / ProofStack / Workfolio / ReelDeck / Workdeck are ruled out.

## Off-device note

This machine has no Xcode / iOS simulator. Compilation and tests run on the cloud macOS
CI runner; local edits are verified there via the `compile` lane.
