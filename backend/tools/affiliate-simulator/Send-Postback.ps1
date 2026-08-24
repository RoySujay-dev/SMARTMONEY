<#
.SYNOPSIS
  Plays the role of Cuelinks: posts Transaction Update callbacks at the
  Smart Money webhook so the conversion -> cashback pipeline can be exercised
  end-to-end without provider credentials.

.EXAMPLE
  $env:SM_WEBHOOK_TOKEN = "<value of Webhooks:CuelinksToken user secret>"
  .\Send-Postback.ps1 -SubId "<TrackingReference from an AffiliateClicks row>" -Scenario happy-path

.NOTES
  -SubId comes from the tracked URL's subid= parameter after tapping
  "Earn Cashback" in the app (or from the AffiliateClicks table).
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$SubId,

    [ValidateSet("happy-path", "rejected", "reversal", "duplicate", "unattributable")]
    [string]$Scenario = "happy-path",

    [string]$BaseUrl = "http://localhost:5256",

    # Stable per run so every step updates the SAME conversion; override to
    # replay a specific transaction id.
    [string]$TransactionId = ("SIM-" + [guid]::NewGuid().ToString("N").Substring(0, 12).ToUpper())
)

$token = $env:SM_WEBHOOK_TOKEN
if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Error "Set SM_WEBHOOK_TOKEN to the Webhooks:CuelinksToken user-secret value first."
    exit 1
}

$uri = "$BaseUrl/api/webhooks/cuelinks?token=$token"

function Send-Update {
    param([string]$Status, [string]$Sub = $SubId, [decimal]$Commission = 250.00)

    $body = @{
        transaction_id   = $TransactionId
        campaign_id      = "SIM-CAMPAIGN"
        sub_id           = $Sub
        status           = $Status
        sale_amount      = 2499.00
        commission       = $Commission
        currency         = "INR"
        transaction_date = (Get-Date).ToUniversalTime().AddHours(-2).ToString("o")
        updated_at       = (Get-Date).ToUniversalTime().ToString("o")
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Post -Uri $uri -Body $body -ContentType "application/json"
    Write-Host ("  {0,-10} -> outcome: {1}" -f $Status, $response.outcome)
}

Write-Host "Simulating '$Scenario' for transaction $TransactionId (sub_id: $SubId)"

switch ($Scenario) {
    "happy-path" {
        # pending creates the Pending cashback; validated confirms it; paid is
        # network settlement only and must NOT move the cashback to PaidOut.
        Send-Update -Status "pending"
        Send-Update -Status "validated"
        Send-Update -Status "paid"
    }
    "rejected" {
        Send-Update -Status "pending"
        Send-Update -Status "rejected"
    }
    "reversal" {
        Send-Update -Status "pending"
        Send-Update -Status "validated"
        Send-Update -Status "reversed"
    }
    "duplicate" {
        # Identical replays must upsert a single conversion + single cashback.
        Send-Update -Status "pending"
        Send-Update -Status "pending"
        Send-Update -Status "validated"
        Send-Update -Status "validated"
    }
    "unattributable" {
        # Unknown sub_id: the conversion must persist (with raw payload) but
        # no cashback is created and the endpoint still returns 200.
        Send-Update -Status "pending" -Sub "unknown-subid-000"
        Send-Update -Status "validated" -Sub "unknown-subid-000"
    }
}

Write-Host "Done. Inspect AffiliateConversions and Cashbacks for transaction $TransactionId."
