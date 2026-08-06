namespace SmartMoney.Application.Contracts.Stores;

public sealed record StoreListItemResponse(
    Guid Id,
    string Name,
    string Slug,
    string? ShortDescription,
    string? LogoUrl,
    string? DefaultCashbackText,
    bool IsFeatured,
    int DisplayOrder);