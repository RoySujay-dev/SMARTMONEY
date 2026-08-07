namespace SmartMoney.Application.Contracts.Stores;

public sealed record StoreDetailsResponse(
    Guid Id,
    string Name,
    string Slug,
    string? ShortDescription,
    string? Description,
    string? LogoUrl,
    string? BannerUrl,
    string WebsiteUrl,
    string? DefaultCashbackText,
    bool IsFeatured);