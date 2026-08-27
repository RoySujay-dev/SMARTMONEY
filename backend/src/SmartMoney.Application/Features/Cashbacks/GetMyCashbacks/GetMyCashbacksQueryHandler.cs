using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Application.Contracts.Cashbacks;

namespace SmartMoney.Application.Features.Cashbacks.GetMyCashbacks;

public sealed class GetMyCashbacksQueryHandler
    : IQueryHandler<GetMyCashbacksQuery, MyCashbackListResponse>
{
    private const int DefaultPageSize = 20;
    private const int MaxPageSize = 100;

    private readonly ICashbackRepository _cashbackRepository;

    public GetMyCashbacksQueryHandler(ICashbackRepository cashbackRepository)
    {
        _cashbackRepository = cashbackRepository;
    }

    public async Task<MyCashbackListResponse> HandleAsync(
        GetMyCashbacksQuery query,
        CancellationToken cancellationToken)
    {
        int page = Math.Max(query.Page, 1);
        int pageSize = query.PageSize <= 0
            ? DefaultPageSize
            : Math.Min(query.PageSize, MaxPageSize);

        var cashbacks = await _cashbackRepository.ListByUserIdAsync(
            query.UserId, page, pageSize, cancellationToken);

        var totalCount = await _cashbackRepository.CountByUserIdAsync(
            query.UserId, cancellationToken);

        var items = cashbacks
            .Select(cashback => new MyCashbackListItemResponse
            {
                Id = cashback.Id,
                StoreName = cashback.AffiliateConversion.AffiliateClick?.Store?.Name,
                CashbackAmount = cashback.CashbackAmount,
                Status = cashback.Status.ToString(),
                CreatedAt = cashback.CreatedAt,
                ExpectedConfirmationDate = cashback.ExpectedConfirmationDate,
                ConfirmedDate = cashback.ConfirmedDate
            })
            .ToList();

        return new MyCashbackListResponse
        {
            Items = items,
            TotalCount = totalCount,
            Page = page,
            PageSize = pageSize
        };
    }
}
