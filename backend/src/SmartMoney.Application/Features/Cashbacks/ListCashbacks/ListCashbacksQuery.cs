using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Cashbacks;
using SmartMoney.Domain.Enums;

namespace SmartMoney.Application.Features.Cashbacks.ListCashbacks;

public sealed class ListCashbacksQuery : IQuery<AdminCashbackListResponse>
{
    public CashbackStatus? Status { get; }

    public int Page { get; }

    public int PageSize { get; }

    public ListCashbacksQuery(CashbackStatus? status, int page, int pageSize)
    {
        Status = status;
        Page = page;
        PageSize = pageSize;
    }
}
