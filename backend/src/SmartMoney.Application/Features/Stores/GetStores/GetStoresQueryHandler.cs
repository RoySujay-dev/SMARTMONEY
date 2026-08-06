using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Application.Contracts.Stores;

namespace SmartMoney.Application.Features.Stores.GetStores;

public sealed class GetStoresQueryHandler : IQueryHandler <GetStoresQuery,IReadOnlyList <StoreListItemResponse>>
{
    private readonly IStoreRepository _storeRepository;

    public GetStoresQueryHandler (IStoreRepository storeRepository)
    {
        _storeRepository = storeRepository;
    }

    public async Task<IReadOnlyList<StoreListItemResponse>> HandleAsync (GetStoresQuery query, CancellationToken cancellationToken)
    {
        var stores = await _storeRepository.GetActiveAsync (cancellationToken);

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