using SmartMoney.Domain.Entities;
using SmartMoney.Domain.Enums;

namespace SmartMoney.Application.Tests.Domain;

public sealed class WalletTransactionTests
{
    [Fact]
    public void Constructor_CapturesAllFields()
    {
        var walletId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var cashbackId = Guid.NewGuid();

        var transaction = new WalletTransaction(
            walletId,
            userId,
            WalletTransactionType.CashbackConfirmed,
            150.00m,
            cashbackId,
            "Cashback confirmed by admin.",
            150.00m,
            0m);

        Assert.Equal(walletId, transaction.WalletId);
        Assert.Equal(userId, transaction.UserId);
        Assert.Equal(WalletTransactionType.CashbackConfirmed, transaction.Type);
        Assert.Equal(150.00m, transaction.Amount);
        Assert.Equal(cashbackId, transaction.CashbackId);
        Assert.Equal("Cashback confirmed by admin.", transaction.Description);
        Assert.Equal(150.00m, transaction.AvailableBalanceAfter);
        Assert.Equal(0m, transaction.PendingBalanceAfter);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-150)]
    public void Constructor_NonPositiveAmount_Throws(decimal amount)
    {
        Assert.Throws<ArgumentException>(() => new WalletTransaction(
            Guid.NewGuid(),
            Guid.NewGuid(),
            WalletTransactionType.CashbackPending,
            amount,
            null,
            null,
            0m,
            0m));
    }
}
