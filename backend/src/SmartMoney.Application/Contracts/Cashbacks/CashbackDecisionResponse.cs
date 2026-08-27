namespace SmartMoney.Application.Contracts.Cashbacks;

/// <summary>
/// Result of an admin approve/reject/reverse decision: the cashback's new
/// status plus the wallet balances after the decision was applied.
/// </summary>
public sealed class CashbackDecisionResponse
{
    public Guid CashbackId { get; set; }

    public string Status { get; set; } = string.Empty;

    public decimal AvailableBalance { get; set; }

    public decimal PendingBalance { get; set; }
}
