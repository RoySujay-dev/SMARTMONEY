namespace SmartMoney.Application.Contracts.Categories;

public sealed record CategoryListItemResponse(
    Guid Id,
    string Name,
    string Slug,
    string? Description,
    string? IconUrl,
    int DisplayOrder);