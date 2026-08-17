using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Affiliate;
using SmartMoney.Application.Features.Affiliate.CreateAffiliateClick;
using SmartMoney.Application.Features.Affiliate.ResolveAffiliateRedirect;

namespace SmartMoney.Api.Controllers;

[ApiController]
public sealed class AffiliateController : ControllerBase
{
    private readonly ICommandHandler<CreateAffiliateClickCommand, CreateAffiliateClickResponse?> _createClickHandler;
    private readonly ICommandHandler<ResolveAffiliateRedirectCommand, string?> _resolveRedirectHandler;

    public AffiliateController(
        ICommandHandler<CreateAffiliateClickCommand, CreateAffiliateClickResponse?> createClickHandler,
        ICommandHandler<ResolveAffiliateRedirectCommand, string?> resolveRedirectHandler)
    {
        _createClickHandler = createClickHandler;
        _resolveRedirectHandler = resolveRedirectHandler;
    }

    [Authorize]
    [HttpPost("api/affiliate/clicks")]
    [ProducesResponseType(typeof(CreateAffiliateClickResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<CreateAffiliateClickResponse>> CreateClick(
        [FromBody] CreateAffiliateClickRequest request,
        CancellationToken cancellationToken)
    {
        string? userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (!Guid.TryParse(userIdClaim, out Guid userId))
        {
            return Unauthorized();
        }

        var command = new CreateAffiliateClickCommand(
            userId,
            request.StoreId,
            request.OfferId);

        var response = await _createClickHandler.HandleAsync(command, cancellationToken);

        if (response is null)
        {
            return NotFound(new
            {
                message = "Cashback is not available for this store or offer."
            });
        }

        return Ok(response);
    }

    [AllowAnonymous]
    [HttpGet("r/{redirectToken}")]
    [ProducesResponseType(StatusCodes.Status302Found)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Redirect(
        string redirectToken,
        CancellationToken cancellationToken)
    {
        var command = new ResolveAffiliateRedirectCommand(redirectToken);

        var destinationUrl = await _resolveRedirectHandler.HandleAsync(command, cancellationToken);

        if (destinationUrl is null)
        {
            return NotFound();
        }

        return base.Redirect(destinationUrl);
    }
}
