namespace SmartMoney.Application.Contracts.Offers;

public sealed record OfferListItemResponse(
    Guid Id,
    Guid StoreId,
    string StoreName,
    string StoreSlug,
    string Title,
    string Slug,
    string OfferType,
    string? ShortDescription,
    string? ImageUrl,
    string CashbackType,
    decimal? CashbackValue,
    string? CashbackText,
    string? CouponCode,
    DateTime? StartAt,
    DateTime? EndAt,
    bool IsFeatured,
    int Priority);