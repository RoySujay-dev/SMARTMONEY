using SmartMoney.Domain.Entities;
using SmartMoney.Domain.Enums;

namespace SmartMoney.Application.Tests.Domain;

public sealed class CashbackTests
{
    private static Cashback NewCashback(decimal amount = 150.00m)
    {
        return new Cashback(
            userId: Guid.NewGuid(),
            walletId: Guid.NewGuid(),
            affiliateConversionId: Guid.NewGuid(),
            cashbackAmount: amount,
            expectedConfirmationDate: DateTime.UtcNow.AddDays(60));
    }

    [Fact]
    public void NewCashback_StartsPending()
    {
        Assert.Equal(CashbackStatus.Pending, NewCashback().Status);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    public void Constructor_RejectsNonPositiveAmount(decimal amount)
    {
        Assert.Throws<ArgumentException>(() => NewCashback(amount));
    }

    [Fact]
    public void FlagForReview_FromPending_SetsAwaitingAdminReview()
    {
        var cashback = NewCashback();

        cashback.FlagForReview();

        Assert.Equal(CashbackStatus.AwaitingAdminReview, cashback.Status);
    }

    [Fact]
    public void FlagForReview_FromConfirmed_SetsAwaitingAdminReview()
    {
        // The network reports a reversal after an admin already confirmed —
        // it goes back to review rather than being auto-reversed.
        var cashback = NewCashback();
        cashback.Confirm();

        cashback.FlagForReview();

        Assert.Equal(CashbackStatus.AwaitingAdminReview, cashback.Status);
    }

    [Fact]
    public void FlagForReview_FromRejected_Throws()
    {
        var cashback = NewCashback();
        cashback.Reject();

        Assert.Throws<InvalidOperationException>(cashback.FlagForReview);
    }

    [Fact]
    public void FlagForReview_FromAwaitingAdminReview_Throws()
    {
        // Duplicate/out-of-order network postbacks must not re-trigger this —
        // the ingestion processor guards on this too, but the domain itself
        // should refuse a redundant transition.
        var cashback = NewCashback();
        cashback.FlagForReview();

        Assert.Throws<InvalidOperationException>(cashback.FlagForReview);
    }

    [Fact]
    public void Confirm_FromPending_SetsConfirmedAndDate()
    {
        // Admin can confirm directly from Pending on out-of-band evidence,
        // without waiting for a network status to flag it for review first.
        var cashback = NewCashback();

        cashback.Confirm();

        Assert.Equal(CashbackStatus.Confirmed, cashback.Status);
        Assert.NotNull(cashback.ConfirmedDate);
    }

    [Fact]
    public void Confirm_FromAwaitingAdminReview_SetsConfirmed()
    {
        var cashback = NewCashback();
        cashback.FlagForReview();

        cashback.Confirm();

        Assert.Equal(CashbackStatus.Confirmed, cashback.Status);
    }

    [Fact]
    public void Confirm_Twice_Throws()
    {
        var cashback = NewCashback();
        cashback.Confirm();

        Assert.Throws<InvalidOperationException>(cashback.Confirm);
    }

    [Fact]
    public void Reject_FromPending_SetsRejected()
    {
        var cashback = NewCashback();

        cashback.Reject();

        Assert.Equal(CashbackStatus.Rejected, cashback.Status);
    }

    [Fact]
    public void Reject_FromAwaitingAdminReview_SetsRejected()
    {
        var cashback = NewCashback();
        cashback.FlagForReview();

        cashback.Reject();

        Assert.Equal(CashbackStatus.Rejected, cashback.Status);
    }

    [Fact]
    public void Reject_AfterConfirm_Throws()
    {
        var cashback = NewCashback();
        cashback.Confirm();

        Assert.Throws<InvalidOperationException>(cashback.Reject);
    }

    [Fact]
    public void Reverse_FromAwaitingAdminReview_AfterConfirm_SetsReversed()
    {
        var cashback = NewCashback();
        cashback.Confirm();
        cashback.FlagForReview();

        cashback.Reverse();

        Assert.Equal(CashbackStatus.Reversed, cashback.Status);
    }

    [Fact]
    public void Reverse_DirectlyFromConfirmed_Throws()
    {
        // Reversal must pass through admin review — it can no longer happen
        // directly off Confirmed.
        var cashback = NewCashback();
        cashback.Confirm();

        Assert.Throws<InvalidOperationException>(cashback.Reverse);
    }

    [Fact]
    public void Reverse_FromAwaitingAdminReview_NeverConfirmed_Throws()
    {
        // AwaitingAdminReview is reachable straight from Pending too (a
        // rejected-from-birth conversion) — reversing something that was
        // never actually confirmed must still be refused.
        var cashback = NewCashback();
        cashback.FlagForReview();

        Assert.Throws<InvalidOperationException>(cashback.Reverse);
    }

    [Fact]
    public void Reverse_FromPending_Throws()
    {
        Assert.Throws<InvalidOperationException>(NewCashback().Reverse);
    }

    [Fact]
    public void MarkAsPaidOut_FromConfirmed_SetsPaidOut()
    {
        var cashback = NewCashback();
        cashback.Confirm();

        cashback.MarkAsPaidOut();

        Assert.Equal(CashbackStatus.PaidOut, cashback.Status);
    }

    [Fact]
    public void MarkAsPaidOut_FromPending_Throws()
    {
        // The guard that separates "network was paid" from "user was paid":
        // nothing can jump Pending -> PaidOut.
        Assert.Throws<InvalidOperationException>(NewCashback().MarkAsPaidOut);
    }
}
