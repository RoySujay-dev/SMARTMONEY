using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Search;
using SmartMoney.Application.Features.Search;

namespace SmartMoney.Api.Controllers;

[ApiController]
[Route("api/search")]
public sealed class SearchController : ControllerBase
{
    private readonly IQueryHandler<SearchQuery, SearchResultResponse> _searchHandler;
    public SearchController(
        IQueryHandler<SearchQuery, SearchResultResponse> searchHandler)
    {
        _searchHandler = searchHandler;
    }

    [HttpGet]
    [ProducesResponseType(typeof(SearchResultResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<SearchResultResponse>> Search(
    [FromQuery] string q, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(q))
        {
            return BadRequest("Search query is required.");
        }

        var query = new SearchQuery(q.Trim());

        var result = await _searchHandler.HandleAsync(query,cancellationToken);

        return Ok(result);
    }
}