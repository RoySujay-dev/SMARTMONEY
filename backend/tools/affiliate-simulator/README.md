# Affiliate Simulator

Plays the role of Cuelinks so the full tracking pipeline can be demonstrated
without provider credentials:

```
app login -> Earn Cashback -> POST /api/affiliate/clicks -> GET /r/{token}
    -> merchant URL carrying ?subid={TrackingReference}   (mock network client)
simulator -> POST /api/webhooks/cuelinks?token=...        (this tool)
    -> AffiliateConversion upsert (idempotent)
    -> Cashback created/transitioned (never PaidOut from a network status)
```

## Setup

1. Backend running locally with the `Webhooks:CuelinksToken` user secret set.
2. Export the token for the script:

```powershell
$env:SM_WEBHOOK_TOKEN = "<Webhooks:CuelinksToken value>"
```

3. Tap **Earn Cashback** in the app (logged in, store with an active affiliate
   mapping). Grab the `subid` query value from the merchant URL you land on,
   or read `TrackingReference` from the newest `AffiliateClicks` row.

## Scenarios

```powershell
.\Send-Postback.ps1 -SubId <ref> -Scenario happy-path      # pending -> validated -> paid
.\Send-Postback.ps1 -SubId <ref> -Scenario rejected        # pending -> rejected
.\Send-Postback.ps1 -SubId <ref> -Scenario reversal        # validated then reversed
.\Send-Postback.ps1 -SubId <ref> -Scenario duplicate       # replays; single conversion+cashback
.\Send-Postback.ps1 -SubId <ref> -Scenario unattributable  # unknown sub_id kept for review
```

Expected after `happy-path`: one `AffiliateConversions` row (NetworkStatus
`paid`), one `Cashbacks` row with Status **Confirmed** (2) — never PaidOut —
and `CashbackAmount = commission x UserSharePercent` from `CashbackSettings`.

The payload field names mirror the publicly documented Cuelinks Transaction
Update conventions; verify against a live account before pointing real
postbacks here.
