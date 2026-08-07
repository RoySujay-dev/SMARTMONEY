using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Categories;

namespace SmartMoney.Application.Features.Categories.GetCategories;

public sealed record GetCategoriesQuery
    : IQuery<IReadOnlyList<CategoryListItemResponse>>;