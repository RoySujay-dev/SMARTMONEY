using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Offers;

namespace SmartMoney.Application.Features.Stores.GetStoreOffers;

public sealed record GetStoreOffersQuery(string StoreSlug) : IQuery<IReadOnlyList<OfferListItemResponse>>;