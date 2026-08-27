namespace SmartMoney.Application.Contracts.Wallets;

public sealed class MyWalletResponse
{
    public decimal AvailableBalance { get; set; }

    public decimal PendingBalance { get; set; }

    public decimal TotalEarned { get; set; }

    public decimal TotalWithdrawn { get; set; }
}
