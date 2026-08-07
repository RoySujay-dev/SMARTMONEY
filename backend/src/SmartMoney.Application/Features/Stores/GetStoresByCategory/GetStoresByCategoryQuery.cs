using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Stores;

namespace SmartMoney.Application.Features.Stores.GetStoresByCategory;

public sealed record GetStoresByCategoryQuery(
    string CategorySlug)
    : IQuery<IReadOnlyList<StoreListItemResponse>>;