using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Application.Contracts.Stores;

namespace SmartMoney.Application.Features.Stores.GetStoreDetails;

public sealed class GetStoreDetailsQueryHandler : IQueryHandler <GetStoreDetailsQuery, StoreDetailsResponse?>
{
    private readonly IStoreRepository _storeRepository;

    public GetStoreDetailsQueryHandler (IStoreRepository storeRepository)
    {
        _storeRepository = storeRepository;
    }

    public async Task<StoreDetailsResponse?> HandleAsync (GetStoreDetailsQuery query, CancellationToken cancellationToken)
    {
        var store = await _storeRepository.GetActiveBySlugAsync (query.Slug, cancellationToken);

        if (store is null)
        {
            return null;
        }

        return new StoreDetailsResponse(
            store.Id,
            store.Name,
            store.Slug,
            store.ShortDescription,
            store.Description,
            store.LogoUrl,
            store.BannerUrl,
            store.WebsiteUrl,
            store.DefaultCashbackText,
            store.IsFeatured);
    }
}