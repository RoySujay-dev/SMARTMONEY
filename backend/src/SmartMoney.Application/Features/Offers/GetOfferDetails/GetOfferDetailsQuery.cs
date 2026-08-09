using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Offers;

namespace SmartMoney.Application.Features.Offers.GetOfferDetails;

public sealed record GetOfferDetailsQuery(string Slug) : IQuery<OfferDetailsResponse?>;