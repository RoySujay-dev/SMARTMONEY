namespace SmartMoney.Application.Contracts.Wallets;

public sealed class WalletTransactionListResponse
{
    public IReadOnlyList<WalletTransactionListItemResponse> Items { get; set; } =
        Array.Empty<WalletTransactionListItemResponse>();

    public int TotalCount { get; set; }

    public int Page { get; set; }

    public int PageSize { get; set; }
}
