using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Application.Contracts.Categories;

namespace SmartMoney.Application.Features.Categories.GetCategories;

public sealed class GetCategoriesQueryHandler : IQueryHandler<GetCategoriesQuery,IReadOnlyList<CategoryListItemResponse>>
{
    private readonly ICategoryRepository _categoryRepository;

    public GetCategoriesQueryHandler(ICategoryRepository categoryRepository)
    {
        _categoryRepository = categoryRepository;
    }

    public async Task<IReadOnlyList<CategoryListItemResponse>> HandleAsync(GetCategoriesQuery query,CancellationToken cancellationToken)
    {
        var categories = await _categoryRepository.GetActiveAsync(cancellationToken);

        return categories
            .Select(category => new CategoryListItemResponse(
                    category.Id,
                    category.Name,
                    category.Slug,
                    category.Description,
                    category.IconUrl,
                    category.DisplayOrder)
            )
            .ToList();
    }
}