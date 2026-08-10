namespace SmartMoney.Application.Contracts.Offers;

public sealed record OfferDetailsResponse(
    Guid Id,
    Guid StoreId,
    string StoreName,
    string StoreSlug,
    string? StoreLogoUrl,
    string Title,
    string Slug,
    string OfferType,
    string? ShortDescription,
    string? Description,
    string? TermsAndConditions,
    string? ImageUrl,
    string CashbackType,
    decimal? CashbackValue,
    string? CashbackText,
    string? CouponCode,
    string DestinationUrl,
    DateTime? StartAt,
    DateTime? EndAt,
    bool IsFeatured);