using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Stores;

namespace SmartMoney.Application.Features.Stores.GetStoreDetails;

public sealed record GetStoreDetailsQuery(string Slug) : IQuery<StoreDetailsResponse?>;