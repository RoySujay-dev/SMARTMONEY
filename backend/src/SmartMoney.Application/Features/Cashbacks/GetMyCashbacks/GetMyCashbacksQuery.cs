using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Cashbacks;

namespace SmartMoney.Application.Features.Cashbacks.GetMyCashbacks;

public sealed class GetMyCashbacksQuery : IQuery<MyCashbackListResponse>
{
    public Guid UserId { get; }

    public int Page { get; }

    public int PageSize { get; }

    public GetMyCashbacksQuery(Guid userId, int page, int pageSize)
    {
        UserId = userId;
        Page = page;
        PageSize = pageSize;
    }
}
