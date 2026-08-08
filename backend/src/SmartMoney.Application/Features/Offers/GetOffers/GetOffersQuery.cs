using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Offers;

namespace SmartMoney.Application.Features.Offers.GetOffers;

public sealed record GetOffersQuery: IQuery<IReadOnlyList<OfferListItemResponse>>;