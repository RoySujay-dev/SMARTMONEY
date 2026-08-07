using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Categories;
using SmartMoney.Application.Contracts.Stores;
using SmartMoney.Application.Features.Categories.GetCategories;
using SmartMoney.Application.Features.Stores.GetStoresByCategory;

namespace SmartMoney.Api.Controllers;

[ApiController]
[Route("api/categories")]
public sealed class CategoriesController : ControllerBase
{
    private readonly IQueryHandler<
        GetCategoriesQuery,
        IReadOnlyList<CategoryListItemResponse>> _getCategoriesHandler;

    private readonly IQueryHandler<
        GetStoresByCategoryQuery,
        IReadOnlyList<StoreListItemResponse>> _getStoresByCategoryHandler;

    public CategoriesController(
        IQueryHandler<
            GetCategoriesQuery,
            IReadOnlyList<CategoryListItemResponse>> getCategoriesHandler,
        IQueryHandler<
            GetStoresByCategoryQuery,
            IReadOnlyList<StoreListItemResponse>> getStoresByCategoryHandler)
    {
        _getCategoriesHandler = getCategoriesHandler;
        _getStoresByCategoryHandler = getStoresByCategoryHandler;
    }

    [HttpGet]
    [ProducesResponseType(
        typeof(IReadOnlyList<CategoryListItemResponse>),
        StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<CategoryListItemResponse>>> GetAll(
        CancellationToken cancellationToken)
    {
        var query = new GetCategoriesQuery();

        var categories = await _getCategoriesHandler.HandleAsync(
            query,
            cancellationToken);

        return Ok(categories);
    }

    [HttpGet("{slug}/stores")]
    [ProducesResponseType(
        typeof(IReadOnlyList<StoreListItemResponse>),
        StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<StoreListItemResponse>>> GetStores(
        string slug,
        CancellationToken cancellationToken)
    {
        var query = new GetStoresByCategoryQuery(slug);

        var stores = await _getStoresByCategoryHandler.HandleAsync(
            query,
            cancellationToken);

        return Ok(stores);
    }
}