using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Stores;

namespace SmartMoney.Application.Features.Stores.GetStores;

public sealed record GetStoresQuery : IQuery<IReadOnlyList<StoreListItemResponse>>;