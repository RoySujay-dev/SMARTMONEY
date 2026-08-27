using SmartMoney.Domain.Common;
using SmartMoney.Domain.Enums;

namespace SmartMoney.Domain.Entities;

/// <summary>
/// Immutable ledger entry recording one wallet balance mutation. Every change
/// to a wallet's balances writes exactly one of these in the same unit of
/// work, so the ledger can always be replayed against the balances.
///
/// Convention: mutate the wallet FIRST, then construct the entry from the
/// wallet's post-mutation balances so the snapshots are audit-accurate.
/// </summary>
public class WalletTransaction : BaseEntity
{
    public Guid WalletId { get; private set; }

    public Guid UserId { get; private set; }

    public WalletTransactionType Type { get; private set; }

    /// <summary>
    /// Always positive; direction and balance bucket are implied by
    /// <see cref="Type"/>.
    /// </summary>
    public decimal Amount { get; private set; }

    /// <summary>Null for non-cashback entries (M5 withdrawals).</summary>
    public Guid? CashbackId { get; private set; }

    public string? Description { get; private set; }

    /// <summary>Wallet's AvailableBalance after this mutation.</summary>
    public decimal AvailableBalanceAfter { get; private set; }

    /// <summary>Wallet's PendingBalance after this mutation.</summary>
    public decimal PendingBalanceAfter { get; private set; }

    public Wallet Wallet { get; private set; } = null!;

    public User User { get; private set; } = null!;

    public Cashback? Cashback { get; private set; }

    private WalletTransaction()
    {
    }

    public WalletTransaction(
        Guid walletId,
        Guid userId,
        WalletTransactionType type,
        decimal amount,
        Guid? cashbackId,
        string? description,
        decimal availableBalanceAfter,
        decimal pendingBalanceAfter)
    {
        if (amount <= 0)
            throw new ArgumentException("Amount must be greater than zero.");

        WalletId = walletId;
        UserId = userId;
        Type = type;
        Amount = amount;
        CashbackId = cashbackId;
        Description = description;
        AvailableBalanceAfter = availableBalanceAfter;
        PendingBalanceAfter = pendingBalanceAfter;
    }
}
