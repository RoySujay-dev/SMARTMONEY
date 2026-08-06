using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Categories;
using SmartMoney.Application.Features.Categories.GetCategories;

namespace SmartMoney.Api.Controllers;

[ApiController]
[Route("api/categories")]
public sealed class CategoriesController : ControllerBase
{
    private readonly IQueryHandler<
        GetCategoriesQuery,
        IReadOnlyList<CategoryListItemResponse>> _getCategoriesHandler;

    public CategoriesController(IQueryHandler<GetCategoriesQuery,IReadOnlyList<CategoryListItemResponse>> getCategoriesHandler)
    {
        _getCategoriesHandler = getCategoriesHandler;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<CategoryListItemResponse>),StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<CategoryListItemResponse>>> GetAll(CancellationToken cancellationToken)
    {
        var query = new GetCategoriesQuery();

        var categories = await _getCategoriesHandler.HandleAsync(
            query,
            cancellationToken);

        return Ok(categories);
    }
}