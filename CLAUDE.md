# ChengYu — Daily Chinese Idioms

iOS app + widget extension. One four-character Chinese idiom (成语) a day, on the home screen.
App Store ID `6740611324` · bundle `com.wilsonlimsetiawan.dailychineseidioms` · team `JU395NH3KL`

## Releasing

**Read `scripts/RELEASE.md` before any release work.** The whole flow — archive, sign,
upload, attach, submit — runs headlessly via `xcodebuild` plus `scripts/asc.py` and the App
Store Connect API. Do not drive the ASC website for this; it fails silently when the session
expires and gives no error message. That file also documents the App Store gotchas that have
each cost hours (IAP screenshot dimensions, review-notes save order, consumable + version
coupling, burned Product IDs).

## Audience

~99% English speakers learning Chinese. Not native speakers. This decides most product
calls: no Chinese-language App Store localizations (drafted copy is parked in
`AppStore/ASO.md`), and listing copy is written for learners.

## Architecture

- **`Shared/`** is compiled into both the app and the widget: `AppGroup.swift` (preference
  keys, `MeaningDisplayMode`, widget reload), `IdiomProvider.swift`, `Resources/idioms.json`
  (995 idioms), `Resources/Idiom.swift`.
- **Preferences live in the app group `group.com.wilsonlimsetiawan.dailychinese`.** Both
  targets must be entitled to *this exact string*. A mismatch here shipped once and made
  every widget setting silently do nothing — verify entitlements on every archive.
- **Xcode 16 file-system synchronized groups**: new `.swift` files in `DailyChineseIdiom/`,
  `DailyIdiom/`, or `Shared/` are picked up automatically, no pbxproj edit needed.
- The idiom of the day is `idioms[daysSince(2025-01-01) % idioms.count]`, changing at midnight.

## Traps

- **Never use `@AppStorage` inside an `ObservableObject`.** It persists the value but never
  fires `objectWillChange`, so observing views keep showing the old setting. Use `@Published`
  plus explicit writes, as `UserPreferences` does now.
- **267 of 995 idioms (27%) look identical in simplified and traditional.** The character
  toggle can legitimately appear to do nothing — verify via the example sentence, History,
  or the Settings preview (塞翁失马 → 塞翁失馬, which always differs).
- **Audio needs an active `AVAudioSession` with `.playback`.** Without it the default
  `.soloAmbient` category is muted by the ring/silent switch, so pronunciation is inaudible
  with no error.
- **Tip jar products need the scheme's StoreKit Configuration set to `TipJar.storekit`**, and
  only load under an Xcode debug session (⌘R), never from the simulator's home screen.

## Product decisions already made

Free forever, **no ads** (at this scale ad revenue would be ~$10–40/month and would cost the
design quality reviewers praise). Monetization is an optional two-tier tip jar that unlocks
nothing: `.tip.small` $1.99 🥟 and `.tip.large` $19.99 🍽️ — the $19.99 is deliberate. A
`.tip.medium` $4.99 exists in App Store Connect as an inert draft; re-add its ID to
`TipJarManager.productIDs` and `TipJar.storekit` to revive it.

App Store name and screenshots are deliberately left alone — see `AppStore/ASO.md` for the
listing copy, character counts, and reasoning.
