namespace SmartMoney.Application.Contracts.Cashbacks;

public sealed class MyCashbackListResponse
{
    public IReadOnlyList<MyCashbackListItemResponse> Items { get; set; } =
        Array.Empty<MyCashbackListItemResponse>();

    public int TotalCount { get; set; }

    public int Page { get; set; }

    public int PageSize { get; set; }
}
