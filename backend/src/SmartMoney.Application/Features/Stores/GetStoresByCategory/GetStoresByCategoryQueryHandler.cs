using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Application.Contracts.Stores;

namespace SmartMoney.Application.Features.Stores.GetStoresByCategory;

public sealed class GetStoresByCategoryQueryHandler
    : IQueryHandler<
        GetStoresByCategoryQuery,
        IReadOnlyList<StoreListItemResponse>>
{
    private readonly IStoreRepository _storeRepository;

    public GetStoresByCategoryQueryHandler(
        IStoreRepository storeRepository)
    {
        _storeRepository = storeRepository;
    }

    public async Task<IReadOnlyList<StoreListItemResponse>> HandleAsync(
        GetStoresByCategoryQuery query,
        CancellationToken cancellationToken)
    {
        var stores =
            await _storeRepository.GetActiveByCategorySlugAsync(
                query.CategorySlug,
                cancellationToken);

        return stores
            .Select(store => new StoreListItemResponse(
                store.Id,
                store.Name,
                store.Slug,
                store.ShortDescription,
                store.LogoUrl,
                store.DefaultCashbackText,
                store.IsFeatured,
                store.DisplayOrder))
            .ToList();
    }
}