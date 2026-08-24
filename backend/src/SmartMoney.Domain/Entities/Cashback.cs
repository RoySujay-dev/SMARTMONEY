using SmartMoney.Domain.Common;
using SmartMoney.Domain.Enums;

namespace SmartMoney.Domain.Entities;

/// <summary>
/// What Smart Money owes the user. Network facts (commission, purchase date,
/// provider status) live on <see cref="AffiliateConversion"/>; this entity
/// only tracks the user-facing reward and its lifecycle. Status changes here
/// never mutate wallet balances — that is the wallet ledger's job (M4).
///
/// MVP rule: automated code (the affiliate ingestion pipeline) may only ever
/// create a Cashback as Pending and move it to AwaitingAdminReview via
/// <see cref="FlagForReview"/>. Confirm/Reject/Reverse are admin-only actions
/// — nothing about a network status alone is allowed to trigger them.
/// </summary>
public class Cashback : BaseEntity
{
    public Guid UserId { get; private set; }

    public Guid WalletId { get; private set; }

    public Guid AffiliateConversionId { get; private set; }

    public decimal CashbackAmount { get; private set; }

    public CashbackStatus Status { get; private set; }

    public DateTime ExpectedConfirmationDate { get; private set; }

    public DateTime? ConfirmedDate { get; private set; }

    public User User { get; private set; } = null!;

    public Wallet Wallet { get; private set; } = null!;

    public AffiliateConversion AffiliateConversion { get; private set; } = null!;

    private Cashback()
    {
    }

    public Cashback(
        Guid userId,
        Guid walletId,
        Guid affiliateConversionId,
        decimal cashbackAmount,
        DateTime expectedConfirmationDate)
    {
        if (cashbackAmount <= 0)
            throw new ArgumentException("Cashback amount must be greater than zero.");

        UserId = userId;
        WalletId = walletId;
        AffiliateConversionId = affiliateConversionId;
        CashbackAmount = cashbackAmount;
        ExpectedConfirmationDate = expectedConfirmationDate;

        Status = CashbackStatus.Pending;
    }

    /// <summary>
    /// Called by the automated ingestion pipeline when the network reports a
    /// decisive status (validated/rejected/cancelled/reversed). Queues the
    /// cashback for a human decision instead of acting on the network's word
    /// alone. Valid from Pending (network suggests confirm/reject) or from
    /// Confirmed (network suggests a reversal after the fact).
    /// </summary>
    public void FlagForReview()
    {
        if (Status != CashbackStatus.Pending && Status != CashbackStatus.Confirmed)
            throw new InvalidOperationException(
                "Only pending or confirmed cashback can be flagged for review.");

        Status = CashbackStatus.AwaitingAdminReview;

        MarkAsUpdated();
    }

    /// <summary>
    /// Admin action. Also reachable directly from Pending so an admin can
    /// confirm on out-of-band evidence without waiting for a network status.
    /// </summary>
    public void Confirm()
    {
        if (Status != CashbackStatus.Pending && Status != CashbackStatus.AwaitingAdminReview)
            throw new InvalidOperationException(
                "Only pending or under-review cashback can be confirmed.");

        Status = CashbackStatus.Confirmed;
        ConfirmedDate = DateTime.UtcNow;

        MarkAsUpdated();
    }

    /// <summary>
    /// Admin action. Also reachable directly from Pending for the same
    /// out-of-band-evidence reason as <see cref="Confirm"/>.
    /// </summary>
    public void Reject()
    {
        if (Status != CashbackStatus.Pending && Status != CashbackStatus.AwaitingAdminReview)
            throw new InvalidOperationException(
                "Only pending or under-review cashback can be rejected.");

        Status = CashbackStatus.Rejected;

        MarkAsUpdated();
    }

    /// <summary>
    /// Admin action that finalizes a reversal. Only reachable after
    /// <see cref="FlagForReview"/> moved a previously-confirmed cashback here
    /// (guarded by requiring a prior confirmation, not just the current
    /// status, since AwaitingAdminReview is shared with the confirm/reject
    /// path).
    /// </summary>
    public void Reverse()
    {
        if (Status != CashbackStatus.AwaitingAdminReview)
            throw new InvalidOperationException(
                "Only cashback under review can be reversed.");

        if (ConfirmedDate is null)
            throw new InvalidOperationException(
                "Only previously confirmed cashback can be reversed.");

        Status = CashbackStatus.Reversed;

        MarkAsUpdated();
    }

    /// <summary>
    /// Smart Money paid the user (withdrawal settlement). Never driven by the
    /// affiliate network's own "paid" status, which only means the network was
    /// paid by the advertiser.
    /// </summary>
    public void MarkAsPaidOut()
    {
        if (Status != CashbackStatus.Confirmed)
            throw new InvalidOperationException("Only confirmed cashback can be paid out.");

        Status = CashbackStatus.PaidOut;

        MarkAsUpdated();
    }
}
