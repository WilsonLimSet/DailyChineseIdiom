#!/usr/bin/env python3
"""App Store Connect API client for ChengYu.

Everything the App Store Connect *website* does badly — silent save failures,
sessions that expire mid-edit — this does reliably, with real error messages.

Setup (one time):
    ~/.appstoreconnect/private_keys/AuthKey_<KEYID>.p8   # from ASC > Users and Access > Integrations
    ~/.appstoreconnect/issuer_id.txt                     # the Issuer ID UUID from that same page

Neither file is in this repo and neither should ever be committed.

Usage:
    python3 scripts/asc.py status                  # app, versions, builds, submission state
    python3 scripts/asc.py show                    # current en-US metadata on the editable version
    python3 scripts/asc.py push <metadata.json>    # write description/keywords/promoText/whatsNew
    python3 scripts/asc.py subtitle <metadata.json>  # write subtitle (app-level, all locales)
    python3 scripts/asc.py contact                 # set App Review contact details
    python3 scripts/asc.py attach <buildVersion>   # attach a build (e.g. 1.26) to the editable version
    python3 scripts/asc.py compliance <buildVer>   # declare usesNonExemptEncryption=false
    python3 scripts/asc.py create-version <x.y>    # create a new editable version record (e.g. 1.95)
    python3 scripts/asc.py screenshots <dir> [type]  # replace a screenshot set from a directory
    python3 scripts/asc.py submit                  # submit the review submission (IRREVERSIBLE-ish)

`screenshots` uploads every *.png in <dir>, sorted by filename, and that order becomes
the order shown on the product page — so name them 01-..., 02-... The set is replaced,
not appended to: existing screenshots of that display type are deleted first. Default
display type is APP_IPHONE_67, which is the slot 1320x2868 (6.9in) belongs to.

See scripts/RELEASE.md for the full release runbook.
"""
import glob
import hashlib
import json
import os
import mimetypes
import ssl
import sys
import time
import urllib.error
import urllib.request

import jwt

try:
    import certifi
    SSL_CTX = ssl.create_default_context(cafile=certifi.where())
except ImportError:
    # python.org builds ship without a usable CA bundle; the system one works.
    SSL_CTX = ssl.create_default_context(cafile="/etc/ssl/cert.pem")

APP_ID = "6740611324"
BASE = "https://api.appstoreconnect.apple.com"
EDITABLE_STATES = {"PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED",
                   "METADATA_REJECTED", "WAITING_FOR_REVIEW", "IN_REVIEW"}

# App Review contact — used by the `contact` command.
CONTACT = {
    "contactFirstName": "Wilson",
    "contactLastName": "Lim Setiawan",
    "contactPhone": "+65 97387272",
    "contactEmail": "wilsonlimset@gmail.com",
    "demoAccountRequired": False,
}


def issuer_id():
    env = os.environ.get("ASC_ISSUER_ID")
    if env:
        return env.strip()
    path = os.path.expanduser("~/.appstoreconnect/issuer_id.txt")
    if os.path.exists(path):
        return open(path).read().strip()
    sys.exit("No issuer ID. Save it to ~/.appstoreconnect/issuer_id.txt or set ASC_ISSUER_ID.")


def key_paths():
    paths = []
    for d in ("~/.appstoreconnect/private_keys", "~/.private_keys"):
        paths += glob.glob(os.path.expanduser(d) + "/AuthKey_*.p8")
    return sorted(set(paths))


def api(method, path, token, body=None):
    url = path if path.startswith("http") else BASE + path
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, method=method, data=data)
    req.add_header("Authorization", "Bearer " + token)
    if data:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, context=SSL_CTX) as r:
            raw = r.read()
            return r.status, (json.loads(raw) if raw else {})
    except urllib.error.HTTPError as e:
        raw = e.read()
        try:
            return e.code, json.loads(raw)
        except Exception:
            return e.code, {"raw": raw.decode(errors="replace")[:800]}


def auth():
    """First key that can read this app wins. Key material is never printed."""
    issuer = issuer_id()
    for p in key_paths():
        key_id = os.path.basename(p).replace("AuthKey_", "").replace(".p8", "")
        now = int(time.time())
        tok = jwt.encode({"iss": issuer, "iat": now, "exp": now + 1200,
                          "aud": "appstoreconnect-v1"},
                         open(p).read(), algorithm="ES256",
                         headers={"kid": key_id, "typ": "JWT"})
        status, body = api("GET", f"/v1/apps/{APP_ID}", tok)
        if status == 200:
            print(f"auth: key {key_id} -> {body['data']['attributes']['name']}")
            return tok
        print(f"auth: key {key_id} rejected (HTTP {status})")
    sys.exit("No key could read this app.")


def editable_version(tok):
    status, vers = api("GET", f"/v1/apps/{APP_ID}/appStoreVersions?limit=10", tok)
    if status != 200:
        sys.exit(f"versions: HTTP {status} {vers}")
    for v in vers["data"]:
        a = v["attributes"]
        state = a.get("appStoreState") or a.get("appVersionState")
        if state in EDITABLE_STATES:
            return v["id"], a["versionString"], state
    sys.exit("No editable version. Create one in App Store Connect first.")


def en_us_localization(tok, version_id):
    status, locs = api("GET", f"/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations", tok)
    if status != 200:
        sys.exit(f"localizations: HTTP {status} {locs}")
    for l in locs["data"]:
        if l["attributes"]["locale"] == "en-US":
            return l["id"]
    sys.exit("No en-US localization.")


def builds(tok):
    """All builds, newest first. The API rejects sort=-uploadedDate, so sort locally."""
    out, url = [], f"/v1/apps/{APP_ID}/builds?limit=200"
    while url:
        status, page = api("GET", url, tok)
        if status != 200:
            sys.exit(f"builds: HTTP {status} {page}")
        out += page["data"]
        url = page.get("links", {}).get("next")
    return sorted(out, key=lambda b: b["attributes"].get("uploadedDate") or "", reverse=True)


def find_build(tok, version_string):
    for b in builds(tok):
        if b["attributes"].get("version") == version_string:
            return b
    sys.exit(f"No build {version_string} found.")


def submission(tok):
    status, subs = api("GET", f"/v1/apps/{APP_ID}/reviewSubmissions?limit=10", tok)
    if status != 200:
        sys.exit(f"submissions: HTTP {status} {subs}")
    for s in subs["data"]:
        if s["attributes"].get("state") in ("READY_FOR_REVIEW", "UNRESOLVED_ISSUES"):
            return s
    return None


def cmd_status(tok):
    vid, vstr, vstate = editable_version(tok)
    print(f"\neditable version: {vstr}  [{vstate}]  id={vid}")
    status, bv = api("GET", f"/v1/appStoreVersions/{vid}/build", tok)
    attached = (bv.get("data") or {})
    print("attached build:", attached.get("attributes", {}).get("version", "NONE") if attached else "NONE")
    print("\nrecent builds:")
    for b in builds(tok)[:5]:
        a = b["attributes"]
        print(f"  {a.get('version'):>6}  {a.get('processingState'):<10} uploaded={a.get('uploadedDate')}")
    s = submission(tok)
    print("\nopen submission:", s["id"] if s else "none",
          f"[{s['attributes'].get('state')}]" if s else "")


def cmd_show(tok):
    vid, vstr, _ = editable_version(tok)
    loc = en_us_localization(tok, vid)
    status, l = api("GET", f"/v1/appStoreVersionLocalizations/{loc}", tok)
    a = l["data"]["attributes"]
    print(f"\n=== {vstr} en-US ===")
    for f in ("promotionalText", "keywords", "whatsNew"):
        print(f"\n--- {f} ---\n{a.get(f)}")
    print(f"\n--- description (first 200) ---\n{(a.get('description') or '')[:200]}")


# Only these live on appStoreVersionLocalizations. `subtitle` does NOT — it belongs to
# appInfoLocalizations and is pushed by `cmd_subtitle`. Sending it here makes Apple reject
# the whole PATCH, which is how the subtitle silently stayed empty from v1.07 to v1.93.
VERSION_LOC_FIELDS = {"description", "keywords", "marketingUrl", "promotionalText",
                      "supportUrl", "whatsNew"}


def cmd_push(tok, path):
    vid, vstr, _ = editable_version(tok)
    loc = en_us_localization(tok, vid)
    raw = json.load(open(path))
    attrs = {k: v for k, v in raw.items() if k in VERSION_LOC_FIELDS}
    skipped = sorted(set(raw) - VERSION_LOC_FIELDS)
    if skipped:
        print(f"skipping (not version-localization fields): {', '.join(skipped)}")
        if "subtitle" in skipped:
            print("  -> run `asc.py subtitle <metadata.json>` to push the subtitle")
    status, r = api("PATCH", f"/v1/appStoreVersionLocalizations/{loc}", tok,
                    {"data": {"type": "appStoreVersionLocalizations", "id": loc, "attributes": attrs}})
    print("PATCH metadata ->", status)
    if status != 200:
        print(json.dumps(r, indent=1)[:1200])


def cmd_subtitle(tok, path):
    """Subtitle is app-level (appInfoLocalizations), one row per locale, not version-scoped."""
    sub = json.load(open(path)).get("subtitle")
    if not sub:
        sys.exit("No 'subtitle' key in that file.")
    if len(sub) > 30:
        sys.exit(f"Subtitle is {len(sub)} chars; Apple's limit is 30.")
    status, infos = api("GET", f"/v1/apps/{APP_ID}/appInfos", tok)
    if status != 200:
        sys.exit(f"appInfos: HTTP {status}")
    for info in infos["data"]:
        state = info["attributes"].get("appStoreState") or info["attributes"].get("state")
        if state not in EDITABLE_STATES:
            continue
        s2, locs = api("GET", f"/v1/appInfos/{info['id']}/appInfoLocalizations", tok)
        for l in locs.get("data", []):
            loc = l["attributes"]["locale"]
            st, r = api("PATCH", f"/v1/appInfoLocalizations/{l['id']}", tok,
                        {"data": {"type": "appInfoLocalizations", "id": l["id"],
                                  "attributes": {"subtitle": sub}}})
            print(f"  {loc:6} subtitle -> {st}")
            if st != 200:
                print(json.dumps(r, indent=1)[:600])


def cmd_contact(tok):
    vid, _, _ = editable_version(tok)
    status, d = api("GET", f"/v1/appStoreVersions/{vid}/appStoreReviewDetail", tok)
    if status == 200 and d.get("data"):
        did = d["data"]["id"]
        st, r = api("PATCH", f"/v1/appStoreReviewDetails/{did}", tok,
                    {"data": {"type": "appStoreReviewDetails", "id": did, "attributes": CONTACT}})
    else:
        st, r = api("POST", "/v1/appStoreReviewDetails", tok,
                    {"data": {"type": "appStoreReviewDetails", "attributes": CONTACT,
                              "relationships": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": vid}}}}})
    print("review contact ->", st)
    if st not in (200, 201):
        print(json.dumps(r, indent=1)[:800])


def cmd_compliance(tok, build_version):
    b = find_build(tok, build_version)
    st, r = api("PATCH", f"/v1/builds/{b['id']}", tok,
                {"data": {"type": "builds", "id": b["id"],
                          "attributes": {"usesNonExemptEncryption": False}}})
    print(f"build {build_version} usesNonExemptEncryption=false ->", st)
    if st != 200:
        print(json.dumps(r, indent=1)[:800])


def cmd_attach(tok, build_version):
    vid, vstr, _ = editable_version(tok)
    b = find_build(tok, build_version)
    if b["attributes"].get("processingState") != "VALID":
        sys.exit(f"build {build_version} is {b['attributes'].get('processingState')}, not VALID yet.")
    st, r = api("PATCH", f"/v1/appStoreVersions/{vid}/relationships/build", tok,
                {"data": {"type": "builds", "id": b["id"]}})
    print(f"attach build {build_version} to {vstr} ->", st)
    if st not in (200, 204):
        print(json.dumps(r, indent=1)[:800])
        return
    st, sub = api("GET", f"/v1/apps/{APP_ID}/reviewSubmissions?limit=10", tok)
    s = submission(tok)
    if not s:
        print("no open submission; create one in ASC or add IAPs for review first")
        return
    st, r = api("POST", "/v1/reviewSubmissionItems", tok,
                {"data": {"type": "reviewSubmissionItems",
                          "relationships": {"reviewSubmission": {"data": {"type": "reviewSubmissions", "id": s["id"]}},
                                            "appStoreVersion": {"data": {"type": "appStoreVersions", "id": vid}}}}})
    print("add version to submission ->", st)
    if st not in (200, 201):
        # The associatedErrors block is where the real reason lives.
        print(json.dumps(r, indent=1)[:1500])


def cmd_create_version(tok, version_string):
    """Create a new editable version record. Idempotent: reports an existing one instead."""
    status, vers = api("GET", f"/v1/apps/{APP_ID}/appStoreVersions?limit=20", tok)
    if status == 200:
        for v in vers["data"]:
            if v["attributes"]["versionString"] == version_string:
                a = v["attributes"]
                state = a.get("appStoreState") or a.get("appVersionState")
                print(f"version {version_string} already exists ({state}) id={v['id']}")
                return
    body = {"data": {
        "type": "appStoreVersions",
        "attributes": {"platform": "IOS", "versionString": version_string},
        "relationships": {"app": {"data": {"type": "apps", "id": APP_ID}}},
    }}
    status, resp = api("POST", "/v1/appStoreVersions", tok, body)
    if status not in (200, 201):
        sys.exit(f"create-version: HTTP {status} {json.dumps(resp)[:600]}")
    a = resp["data"]["attributes"]
    state = a.get("appStoreState") or a.get("appVersionState")
    print(f"created version {a['versionString']} ({state}) id={resp['data']['id']}")


def screenshot_set(tok, loc_id, display_type):
    """The appScreenshotSet for this localization + display type, created if absent."""
    status, sets = api("GET", f"/v1/appStoreVersionLocalizations/{loc_id}/appScreenshotSets", tok)
    if status != 200:
        sys.exit(f"screenshotSets: HTTP {status} {sets}")
    for s in sets["data"]:
        if s["attributes"]["screenshotDisplayType"] == display_type:
            return s["id"], False
    body = {"data": {
        "type": "appScreenshotSets",
        "attributes": {"screenshotDisplayType": display_type},
        "relationships": {"appStoreVersionLocalization": {
            "data": {"type": "appStoreVersionLocalizations", "id": loc_id}}},
    }}
    status, resp = api("POST", "/v1/appScreenshotSets", tok, body)
    if status not in (200, 201):
        sys.exit(f"create set: HTTP {status} {json.dumps(resp)[:600]}")
    return resp["data"]["id"], True


def upload_screenshot(tok, set_id, path):
    """Apple's three-step upload: reserve, PUT the bytes, then commit with a checksum."""
    blob = open(path, "rb").read()
    name = os.path.basename(path)
    body = {"data": {
        "type": "appScreenshots",
        "attributes": {"fileName": name, "fileSize": len(blob)},
        "relationships": {"appScreenshotSet": {
            "data": {"type": "appScreenshotSets", "id": set_id}}},
    }}
    status, resp = api("POST", "/v1/appScreenshots", tok, body)
    if status not in (200, 201):
        sys.exit(f"reserve {name}: HTTP {status} {json.dumps(resp)[:600]}")
    shot_id = resp["data"]["id"]

    for op in resp["data"]["attributes"]["uploadOperations"]:
        chunk = blob[op["offset"]:op["offset"] + op["length"]]
        req = urllib.request.Request(op["url"], method=op["method"], data=chunk)
        for h in op.get("requestHeaders", []):
            req.add_header(h["name"], h["value"])
        try:
            with urllib.request.urlopen(req, context=SSL_CTX) as r:
                if r.status not in (200, 201, 204):
                    sys.exit(f"upload {name}: HTTP {r.status}")
        except urllib.error.HTTPError as e:
            sys.exit(f"upload {name}: HTTP {e.code} {e.read()[:300]}")

    patch = {"data": {"type": "appScreenshots", "id": shot_id,
                      "attributes": {"uploaded": True,
                                     "sourceFileChecksum": hashlib.md5(blob).hexdigest()}}}
    status, resp = api("PATCH", f"/v1/appScreenshots/{shot_id}", tok, patch)
    if status != 200:
        sys.exit(f"commit {name}: HTTP {status} {json.dumps(resp)[:600]}")
    return shot_id


def cmd_screenshots(tok, directory, display_type="APP_IPHONE_67"):
    files = sorted(glob.glob(os.path.join(directory, "*.png")))
    if not files:
        sys.exit(f"no .png files in {directory}")
    vid, vstr, state = editable_version(tok)
    loc_id = en_us_localization(tok, vid)
    print(f"version {vstr} ({state}), display type {display_type}")
    set_id, created = screenshot_set(tok, loc_id, display_type)
    print(f"screenshot set {set_id}{' (created)' if created else ''}")

    # Replace rather than append: a second upload would otherwise duplicate the set.
    status, existing = api("GET", f"/v1/appScreenshotSets/{set_id}/appScreenshots", tok)
    if status == 200 and existing["data"]:
        for shot in existing["data"]:
            st, _ = api("DELETE", f"/v1/appScreenshots/{shot['id']}", tok)
            print(f"  deleted existing {shot['attributes'].get('fileName')} (HTTP {st})")

    for f in files:
        size = os.path.getsize(f)
        shot_id = upload_screenshot(tok, set_id, f)
        print(f"  uploaded {os.path.basename(f)} ({size:,} bytes) id={shot_id}")
    print(f"{len(files)} screenshot(s) uploaded, in filename order.")


def cmd_submit(tok):
    s = submission(tok)
    if not s:
        sys.exit("No open submission to submit.")
    st, r = api("PATCH", f"/v1/reviewSubmissions/{s['id']}", tok,
                {"data": {"type": "reviewSubmissions", "id": s["id"], "attributes": {"submitted": True}}})
    print("SUBMIT ->", st)
    if st == 200:
        a = r["data"]["attributes"]
        print("state:", a.get("state"), "submittedDate:", a.get("submittedDate"))
    else:
        print(json.dumps(r, indent=1)[:1200])


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"
    tok = auth()
    if cmd == "status":
        cmd_status(tok)
    elif cmd == "show":
        cmd_show(tok)
    elif cmd == "push":
        cmd_push(tok, sys.argv[2])
    elif cmd == "subtitle":
        cmd_subtitle(tok, sys.argv[2])
    elif cmd == "contact":
        cmd_contact(tok)
    elif cmd == "compliance":
        cmd_compliance(tok, sys.argv[2])
    elif cmd == "attach":
        cmd_attach(tok, sys.argv[2])
    elif cmd == "create-version":
        cmd_create_version(tok, sys.argv[2])
    elif cmd == "screenshots":
        cmd_screenshots(tok, sys.argv[2], *(sys.argv[3:4] or []))
    elif cmd == "submit":
        cmd_submit(tok)
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
