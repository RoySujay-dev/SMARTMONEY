namespace SmartMoney.Application.Contracts.Wallets;

public sealed class WalletTransactionListItemResponse
{
    public Guid Id { get; set; }

    public string Type { get; set; } = string.Empty;

    public decimal Amount { get; set; }

    public string? Description { get; set; }

    public decimal AvailableBalanceAfter { get; set; }

    public decimal PendingBalanceAfter { get; set; }

    public DateTime CreatedAt { get; set; }
}
