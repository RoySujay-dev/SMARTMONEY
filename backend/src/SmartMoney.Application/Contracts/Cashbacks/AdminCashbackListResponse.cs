namespace SmartMoney.Application.Contracts.Cashbacks;

public sealed class AdminCashbackListResponse
{
    public IReadOnlyList<AdminCashbackListItemResponse> Items { get; set; } =
        Array.Empty<AdminCashbackListItemResponse>();

    public int TotalCount { get; set; }

    public int Page { get; set; }

    public int PageSize { get; set; }
}
