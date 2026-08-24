namespace SmartMoney.Domain.Enums;

public enum CashbackStatus
{
    Pending = 1,

    Confirmed = 2,

    Rejected = 3,

    /// <summary>
    /// Smart Money paid the user. Never set from the affiliate network's own
    /// "paid" status — that only means the network was paid by the advertiser.
    /// </summary>
    PaidOut = 4,

    /// <summary>
    /// The network withdrew an already-confirmed transaction.
    /// </summary>
    Reversed = 5,

    /// <summary>
    /// MVP safety gate: the network reported a decisive status (validated,
    /// rejected, cancelled or reversed), but no automated code is allowed to
    /// act on that alone. An admin must review the linked
    /// AffiliateConversion.NetworkStatus and explicitly Confirm/Reject/Reverse.
    /// </summary>
    AwaitingAdminReview = 6
}
