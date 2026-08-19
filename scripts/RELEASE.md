# Releasing ChengYu

The entire release runs from the command line — archive, sign, upload, attach, submit.
Xcode's UI is not required at any step, and neither is the App Store Connect website.

App Store ID `6740611324` · bundle `com.wilsonlimsetiawan.dailychineseidioms` · team `JU395NH3KL`

## Prerequisites (one time)

| File | What it is |
|---|---|
| `~/.appstoreconnect/private_keys/AuthKey_<KEYID>.p8` | API key from ASC → Users and Access → Integrations |
| `~/.appstoreconnect/issuer_id.txt` | The Issuer ID UUID shown on that same page |

Neither lives in this repo. `scripts/asc.py` tries every key it finds and uses the first
one that can read the app, so having several is fine.

Python needs `pyjwt`. If `urllib` throws `CERTIFICATE_VERIFY_FAILED`, that's the
python.org build shipping without a CA bundle — `asc.py` already falls back to
`/etc/ssl/cert.pem`.

## The release

### 1. Bump the version

`MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `DailyChineseIdioms.xcodeproj/project.pbxproj`
(4 occurrences each — both configs × both targets). Build numbers must be unique per version.

### 2. Archive

```bash
xcodebuild -project DailyChineseIdioms.xcodeproj \
  -scheme DailyChineseIdioms \
  -destination 'generic/platform=iOS' \
  -configuration Release \
  -archivePath /tmp/ChengYu.xcarchive \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$HOME/.appstoreconnect/private_keys/AuthKey_<KEYID>.p8" \
  -authenticationKeyID <KEYID> \
  -authenticationKeyIssuerID "$(cat ~/.appstoreconnect/issuer_id.txt)" \
  archive
```

`-allowProvisioningUpdates` plus the API key lets xcodebuild create the Apple Distribution
certificate if none exists — the same thing Xcode does silently on Distribute.

**Always verify the app group before uploading.** This is the bug that shipped once and
made every widget setting silently do nothing:

```bash
A=/tmp/ChengYu.xcarchive/Products/Applications/DailyChineseIdioms.app
codesign -d --entitlements - --xml "$A" | plutil -p - | grep -A2 application-groups
codesign -d --entitlements - --xml "$A/PlugIns/DailyIdiomExtension.appex" | plutil -p - | grep -A2 application-groups
```

Both must print `group.com.wilsonlimsetiawan.dailychinese`. If they differ, stop.

### 3. Upload

`exportOptions.plist`:

```xml
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>destination</key><string>upload</string>
  <key>teamID</key><string>JU395NH3KL</string>
  <key>signingStyle</key><string>automatic</string>
  <key>uploadSymbols</key><true/>
  <key>manageAppVersionAndBuildNumber</key><false/>
</dict>
```

```bash
xcodebuild -exportArchive \
  -archivePath /tmp/ChengYu.xcarchive \
  -exportOptionsPlist /tmp/exportOptions.plist \
  -exportPath /tmp/export \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$HOME/.appstoreconnect/private_keys/AuthKey_<KEYID>.p8" \
  -authenticationKeyID <KEYID> \
  -authenticationKeyIssuerID "$(cat ~/.appstoreconnect/issuer_id.txt)"
```

Processing takes 5–15 minutes. Poll with `python3 scripts/asc.py status` until the build is `VALID`.

### 4. Metadata, contact, compliance, submit

```bash
python3 scripts/asc.py status                    # what exists right now
python3 scripts/asc.py push AppStore/metadata.json
python3 scripts/asc.py contact
python3 scripts/asc.py compliance 1.26           # required before a build can be reviewed
python3 scripts/asc.py attach 1.26               # attach + add version to the submission
python3 scripts/asc.py show                      # read back before submitting
python3 scripts/asc.py submit                    # last step, ask first
```

A new version record itself still has to be created in the ASC web UI (App Store tab →
`+` next to iOS App). Everything after that is scriptable. Existing screenshots carry
over to a new version automatically — do not re-upload them.

## Things that cost hours once, so read this

**A red Save button with no error message in the ASC web UI means your session expired.**
Not a validation problem. Saves silently 401 while the page still looks logged in. This is
the single best reason to use the API: it returns `ENTITY_ERROR.ATTRIBUTE.REQUIRED` and
similar, with an `associatedErrors` block naming the exact blocking resource.

**IAP review screenshots must match a real App Store screenshot size**, not "at least
640×920" (that guidance is stale). An iPhone 16 Pro screenshot is 1206×2622 and is
**rejected**. Use an iPhone 16 Pro Max simulator: 1320×2868. Apple's wording is
"a screenshot that meets any of the screenshot specifications your app supports."

**IAP Review Information will not save while the screenshot slot is empty** — review notes
silently revert. Upload the screenshot first, then write the notes.

**The first consumable IAP must be submitted together with a new app version.** IAPs alone
will sit at "Unable to Submit for Review" forever.

**Deleting an IAP burns its Product ID permanently**, even for a product that was never
submitted. Leave unwanted ones as drafts instead; a draft that isn't attached to a
submission is inert.

**Tip jar products only appear in the simulator when the scheme's StoreKit Configuration is
set to `TipJar.storekit`** (already set in the shared scheme). Launching the app from the
simulator's home screen instead of ⌘R gives no Xcode debug session, so no products load and
the Tip Jar section correctly hides itself.

**`xcrun simctl` has no storekit subcommand** — StoreKit testing is injected only by Xcode's
debug session. Screenshots of the tip jar can't be automated headlessly.

## App architecture notes worth knowing before editing

**Preferences live in the shared app group `group.com.wilsonlimsetiawan.dailychinese`**,
read by both the app and the widget. `Shared/AppGroup.swift` owns the keys, the
`MeaningDisplayMode` enum, and the widget-reload call.

**Never put `@AppStorage` inside an `ObservableObject`.** It writes the value but never
fires `objectWillChange`, so every observing view keeps rendering the old setting. This
shipped once and made both Settings pickers look completely broken in-app.
`UserPreferences` uses `@Published` + explicit persistence for exactly this reason.

**27% of idioms (187 of 681) are written identically in simplified and traditional.** When
testing the character toggle, check the example sentence or use History — the headline may
legitimately not change. `塞翁失马 → 塞翁失馬` in the Settings preview always differs.
