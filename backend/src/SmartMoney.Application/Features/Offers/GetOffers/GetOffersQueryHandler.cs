using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Application.Contracts.Offers;

namespace SmartMoney.Application.Features.Offers.GetOffers;

public sealed class GetOffersQueryHandler : IQueryHandler<GetOffersQuery,IReadOnlyList<OfferListItemResponse>>
{
    private readonly IOfferRepository _offerRepository;

    public GetOffersQueryHandler(IOfferRepository offerRepository)
    {
        _offerRepository = offerRepository;
    }
    public async Task<IReadOnlyList<OfferListItemResponse>> HandleAsync(GetOffersQuery query,CancellationToken cancellationToken)
    {
        var offers = await _offerRepository.GetActiveAsync(cancellationToken);

        return offers
            .Select(offer => new OfferListItemResponse(
                offer.Id,
                offer.StoreId,
                offer.Store.Name,
                offer.Store.Slug,
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