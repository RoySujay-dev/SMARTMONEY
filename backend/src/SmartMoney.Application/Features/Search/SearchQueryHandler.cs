using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Application.Contracts.Offers;
using SmartMoney.Application.Contracts.Search;
using SmartMoney.Application.Contracts.Stores;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Features.Search;

public sealed class SearchQueryHandler : IQueryHandler<SearchQuery,SearchResultResponse>
{
    private readonly IStoreRepository _storeRepository;
    private readonly IOfferRepository _offerRepository;

    public SearchQueryHandler(IStoreRepository storeRepository,IOfferRepository offerRepository)
    {
        _storeRepository = storeRepository;
        _offerRepository = offerRepository;
    }

    public async Task<SearchResultResponse> HandleAsync(SearchQuery query,CancellationToken cancellationToken)
    {
        var searchTerm = query.Query.Trim().ToLowerInvariant();

        IReadOnlyList<Store> stores;
        IReadOnlyList<Offer> offers;

        if (searchTerm is "store" or "stores" or "brand" or "brands")
        {
            stores = await _storeRepository.GetActiveAsync(cancellationToken);
            offers = Array.Empty<Domain.Entities.Offer>();
        }
        else if (searchTerm is "offer" or "offers" or "deal" or "deals")
        {
            stores = Array.Empty<Domain.Entities.Store>();
            offers = await _offerRepository.GetActiveAsync(cancellationToken);
        }
        else
        {
            stores = await _storeRepository.SearchAsync(
                query.Query,
                cancellationToken);

            offers = await _offerRepository.SearchAsync(
                query.Query,
                cancellationToken);
        }

        var storeResponses = stores
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

        var offerResponses = offers
            .Select(offer => new OfferListItemResponse(
                offer.Id,
                offer.StoreId,
                offer.Store.Name,
                offer.Store.Slug,
                offer.Store.LogoUrl,
                offer.Title,
                offer.Slug,
                offer.OfferType.ToString(),
                offer.ShortDescription,
                offer.ImageUrl,
                offer.CashbackType.ToString(),
                offer.CashbackValue,
                offer.CashbackText,
                offer.CouponCode,
                offer.StartAt,
                offer.EndAt,
                offer.IsFeatured,
                offer.Priority))
            .ToList();

        return new SearchResultResponse(storeResponses,offerResponses);
    }
}