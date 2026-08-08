using SmartMoney.Application.Contracts.Offers;
using SmartMoney.Application.Contracts.Stores;

namespace SmartMoney.Application.Contracts.Search;

public sealed record SearchResultResponse(IReadOnlyList<StoreListItemResponse> Stores,IReadOnlyList<OfferListItemResponse> Offers);