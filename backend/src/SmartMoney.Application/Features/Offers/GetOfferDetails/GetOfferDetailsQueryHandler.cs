using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Application.Contracts.Offers;

namespace SmartMoney.Application.Features.Offers.GetOfferDetails;

public sealed class GetOfferDetailsQueryHandler : IQueryHandler<GetOfferDetailsQuery,OfferDetailsResponse?>
{
    private readonly IOfferRepository _offerRepository;
    public GetOfferDetailsQueryHandler(IOfferRepository offerRepository)
    {
        _offerRepository = offerRepository;
    }
    public async Task<OfferDetailsResponse?> HandleAsync(GetOfferDetailsQuery query,CancellationToken cancellationToken)
    {
        var offer = await _offerRepository.GetActiveBySlugAsync(query.Slug,cancellationToken);

        if (offer is null)
        {
            return null;
        }

        return new OfferDetailsResponse(
            offer.Id,
            offer.StoreId,
            offer.Store.Name,
            offer.Store.Slug,
            offer.Title,
            offer.Slug,
            offer.OfferType.ToString(),
            offer.ShortDescription,
            offer.Description,
            offer.TermsAndConditions,
            offer.ImageUrl,
            offer.CashbackType.ToString(),
            offer.CashbackValue,
            offer.CashbackText,
            offer.CouponCode,
            offer.DestinationUrl,
            offer.StartAt,
            offer.EndAt,
            offer.IsFeatured);
    }
}