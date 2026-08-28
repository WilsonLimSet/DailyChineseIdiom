#!/usr/bin/env python3
"""Pull App Store Connect Analytics Reports for ChengYu.

Companion to asc.py (shares its auth and ~/.appstoreconnect credentials).

Apple only generates analytics once you've *requested* them; the two standing
requests for this app were created 2026-08-27 and are listed by `requests`.
A ONE_TIME_SNAPSHOT backfills ~365 days; ONGOING keeps updating daily. Neither
is instant -- expect 24-48h before the first instance appears.

Usage:
    python3 scripts/asc_analytics.py requests            # the standing report requests
    python3 scripts/asc_analytics.py reports [filter]    # available reports, name-filtered
    python3 scripts/asc_analytics.py instances <reportId> [DAILY|WEEKLY|MONTHLY]
    python3 scripts/asc_analytics.py fetch <instanceId>  # download + print the TSV

The report worth starting with is "App Sessions Standard": it carries
Unique Devices, Total Number of Sessions *and* Total Session Duration --
the closest thing to DAU and time-in-app that exists without an SDK.
"""
import gzip
import io
import os
import sys
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import asc  # noqa: E402


def requests_(tok):
    _, r = asc.api("GET", f"/v1/apps/{asc.APP_ID}/analyticsReportRequests?limit=50", tok)
    for d in r.get("data", []):
        a = d.get("attributes", {})
        stopped = " STOPPED(inactive)" if a.get("stoppedDueToInactivity") else ""
        print(f"{d['id']}  {a.get('accessType')}{stopped}")


def reports(tok, needle=None):
    _, rq = asc.api("GET", f"/v1/apps/{asc.APP_ID}/analyticsReportRequests?limit=50", tok)
    for req in rq.get("data", []):
        print(f"\n=== {req['attributes'].get('accessType')} ({req['id']}) ===")
        _, r = asc.api("GET", f"/v1/analyticsReportRequests/{req['id']}/reports?limit=200", tok)
        for d in r.get("data", []):
            a = d.get("attributes", {})
            name = a.get("name") or ""
            if needle and needle.lower() not in name.lower():
                continue
            print(f"  {d['id']}\n      {a.get('category')} | {name}")


def instances(tok, report_id, gran="DAILY"):
    _, r = asc.api(
        "GET",
        f"/v1/analyticsReports/{report_id}/instances?filter[granularity]={gran}&limit=200",
        tok,
    )
    data = r.get("data", [])
    if not data:
        print(f"No {gran} instances yet. Apple takes 24-48h after the first request.")
        return
    for d in data:
        a = d.get("attributes", {})
        print(f"{d['id']}  {a.get('processingDate')}  {a.get('granularity')}")


def fetch(tok, instance_id):
    _, r = asc.api("GET", f"/v1/analyticsReportInstances/{instance_id}/segments", tok)
    segs = r.get("data", [])
    if not segs:
        print("No segments on that instance (Apple may still be assembling it).")
        return
    for seg in segs:
        url = seg["attributes"]["url"]
        # Segment URLs are pre-signed; they carry their own auth and expire.
        with urllib.request.urlopen(url, context=asc.SSL_CTX) as resp:
            raw = resp.read()
        try:
            text = gzip.GzipFile(fileobj=io.BytesIO(raw)).read().decode()
        except OSError:
            text = raw.decode()  # not every segment comes gzipped
        sys.stdout.write(text)


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    tok = asc.auth()
    cmd, rest = sys.argv[1], sys.argv[2:]
    if cmd == "requests":
        requests_(tok)
    elif cmd == "reports":
        reports(tok, rest[0] if rest else None)
    elif cmd == "instances":
        if not rest:
            sys.exit("instances needs a reportId (see `reports`)")
        instances(tok, rest[0], rest[1] if len(rest) > 1 else "DAILY")
    elif cmd == "fetch":
        if not rest:
            sys.exit("fetch needs an instanceId (see `instances`)")
        fetch(tok, rest[0])
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
