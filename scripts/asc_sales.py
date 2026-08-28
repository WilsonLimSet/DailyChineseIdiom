#!/usr/bin/env python3
"""Pull App Store Connect Sales Reports for ChengYu.

Companion to asc.py (shares its auth and ~/.appstoreconnect credentials).

Unlike the Analytics Reports (see asc_analytics.py), sales data is exact, needs
no advance request, and is available ~1 day after the fact. It is keyed on the
*vendor number*, not the app ID.

Usage:
    python3 scripts/asc_sales.py [days]     # default 60

Apple returns HTTP 404 for a date with no activity at all, which is normal for a
small app -- those days are counted as zero rather than treated as an error.
"""
import collections
import datetime as dt
import gzip
import io
import sys
import os
import urllib.error
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import asc  # noqa: E402

VENDOR = "94070472"
APP_ID = asc.APP_ID  # vendor 94070472 also carries Sunbreak and ChindoSpeak
# Product Type Identifiers. The crucial split: only the "1" family is a NEW
# user. 7 = update and 3 = re-download are both existing users, and a release
# makes the update column spike in a way that looks like growth but is not.
NEW      = {"1", "1F", "1T", "1E", "1EP", "1EU"}
UPDATE   = {"7", "7F", "7T"}
REDOWN   = {"3", "3F", "3T"}


def fetch_day(tok, day):
    q = (f"/v1/salesReports?filter[frequency]=DAILY&filter[reportType]=SALES"
         f"&filter[reportSubType]=SUMMARY&filter[vendorNumber]={VENDOR}"
         f"&filter[reportDate]={day}")
    req = urllib.request.Request(asc.BASE + q)
    req.add_header("Authorization", "Bearer " + tok)
    req.add_header("Accept", "application/a-gzip")
    try:
        with urllib.request.urlopen(req, context=asc.SSL_CTX) as r:
            raw = r.read()
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return []          # no activity that day
        raise
    text = gzip.GzipFile(fileobj=io.BytesIO(raw)).read().decode("utf-8", "replace")
    lines = [l for l in text.splitlines() if l.strip()]
    if len(lines) < 2:
        return []
    hdr = lines[0].split("\t")
    return [dict(zip(hdr, l.split("\t"))) for l in lines[1:]]


def main():
    days = int(sys.argv[1]) if len(sys.argv) > 1 else 60
    tok = asc.auth()
    today = dt.date.today()

    installs = collections.Counter()
    updates = collections.Counter()
    redowns = collections.Counter()
    iap_units = collections.Counter()
    proceeds = collections.defaultdict(float)
    by_week_inst = collections.Counter()
    by_week_rev = collections.defaultdict(float)

    for i in range(1, days + 1):
        day = today - dt.timedelta(days=i)
        for row in fetch_day(tok, day.isoformat()):
            # One vendor number spans every app on the account -- filter to ChengYu.
            if (row.get("Apple Identifier") or "").strip() != APP_ID and \
               not (row.get("Parent Identifier") or "").startswith("com.wilsonlimsetiawan.dailychinese"):
                continue
            units = int(row.get("Units", 0) or 0)
            prc = float(row.get("Developer Proceeds", 0) or 0) * units
            ptype = (row.get("Product Type Identifier") or "").strip()
            sku = (row.get("SKU") or "").strip()
            wk = (day - dt.timedelta(days=day.weekday())).isoformat()
            if ptype in NEW:
                installs[day.isoformat()] += units
                by_week_inst[wk] += units
            elif ptype in UPDATE:
                updates[wk] += units
            elif ptype in REDOWN:
                redowns[wk] += units
            else:
                iap_units[sku] += units
                proceeds[sku] += prc
                by_week_rev[wk] += prc

    total_inst = sum(installs.values())
    print(f"\n=== Last {days} days ===")
    print(f"NEW downloads:          {total_inst}")
    print(f"  per week (avg):       {total_inst / (days / 7):.1f}")
    print(f"Updates (existing users): {sum(updates.values())}")
    print(f"Re-downloads:             {sum(redowns.values())}")

    print("\n=== In-app purchases ===")
    if not iap_units:
        print("  none recorded")
    for sku, u in iap_units.most_common():
        print(f"  {sku:28} units={u:4}  proceeds=${proceeds[sku]:.2f}")
    print(f"  TOTAL proceeds: ${sum(proceeds.values()):.2f}"
          f"   ({sum(proceeds.values()) / (days / 7):.2f}/week avg)")

    print("\n=== By week (Mon-start) ===")
    for wk in sorted(set(by_week_inst) | set(by_week_rev) | set(updates) | set(redowns)):
        print(f"  {wk}  new={by_week_inst[wk]:4}  upd={updates[wk]:4}  "
              f"redl={redowns[wk]:3}  tips=${by_week_rev[wk]:.2f}")


if __name__ == "__main__":
    main()
