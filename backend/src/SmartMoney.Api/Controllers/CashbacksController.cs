using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Cashbacks;
using SmartMoney.Application.Features.Cashbacks.GetMyCashbacks;

namespace SmartMoney.Api.Controllers;

[ApiController]
[Authorize]
public sealed class CashbacksController : ControllerBase
{
    private readonly IQueryHandler<GetMyCashbacksQuery, MyCashbackListResponse> _getMyCashbacksHandler;

    public CashbacksController(
        IQueryHandler<GetMyCashbacksQuery, MyCashbackListResponse> getMyCashbacksHandler)
    {
        _getMyCashbacksHandler = getMyCashbacksHandler;
    }

    [HttpGet("api/cashbacks")]
    [ProducesResponseType(typeof(MyCashbackListResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<MyCashbackListResponse>> GetMyCashbacks(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        string? userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (!Guid.TryParse(userIdClaim, out Guid userId))
        {
            return Unauthorized();
        }

        var response = await _getMyCashbacksHandler.HandleAsync(
            new GetMyCashbacksQuery(userId, page, pageSize), cancellationToken);

        return Ok(response);
    }
}
