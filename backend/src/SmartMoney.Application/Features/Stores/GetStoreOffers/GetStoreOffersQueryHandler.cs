using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Application.Contracts.Offers;

namespace SmartMoney.Application.Features.Stores.GetStoreOffers;

public sealed class GetStoreOffersQueryHandler : IQueryHandler<GetStoreOffersQuery,IReadOnlyList<OfferListItemResponse>>
{
    private readonly IOfferRepository _offerRepository;
    public GetStoreOffersQueryHandler(IOfferRepository offerRepository)
    {
        _offerRepository = offerRepository;
    }
    public async Task<IReadOnlyList<OfferListItemResponse>> HandleAsync(GetStoreOffersQuery query,CancellationToken cancellationToken)
    {
        var offers = await _offerRepository.GetActiveByStoreSlugAsync(query.StoreSlug,cancellationToken);

        return offers
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
    }
}