using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Affiliate;
using SmartMoney.Application.Features.Affiliate.CreateAffiliateClick;
using SmartMoney.Application.Features.Affiliate.IngestAffiliateConversion;
using SmartMoney.Application.Features.Affiliate.ResolveAffiliateRedirect;

namespace SmartMoney.Api.Controllers;

[ApiController]
public sealed class AffiliateController : ControllerBase
{
    private readonly ICommandHandler<CreateAffiliateClickCommand, CreateAffiliateClickResponse?> _createClickHandler;
    private readonly ICommandHandler<ResolveAffiliateRedirectCommand, string?> _resolveRedirectHandler;
    private readonly ICommandHandler<IngestAffiliateConversionCommand, IngestAffiliateConversionResponse> _ingestConversionHandler;

    public AffiliateController(
        ICommandHandler<CreateAffiliateClickCommand, CreateAffiliateClickResponse?> createClickHandler,
        ICommandHandler<ResolveAffiliateRedirectCommand, string?> resolveRedirectHandler,
        ICommandHandler<IngestAffiliateConversionCommand, IngestAffiliateConversionResponse> ingestConversionHandler)
    {
        _createClickHandler = createClickHandler;
        _resolveRedirectHandler = resolveRedirectHandler;
        _ingestConversionHandler = ingestConversionHandler;
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

    // Internal ingestion endpoint for provider conversion data. The future
    // Cuelinks webhook/sync maps its payload into the same command.
    [Authorize(Roles = "Admin,SuperAdmin")]
    [HttpPost("api/affiliate/conversions")]
    [ProducesResponseType(typeof(IngestAffiliateConversionResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<ActionResult<IngestAffiliateConversionResponse>> IngestConversion(
        [FromBody] IngestAffiliateConversionRequest request,
        CancellationToken cancellationToken)
    {
        var command = new IngestAffiliateConversionCommand(
            request.NetworkCode,
            request.NetworkTransactionId,
            request.TrackingReference,
            request.NetworkStatus,
            request.OrderAmount,
            request.CommissionAmount,
            request.Currency,
            request.TransactionOccurredAt,
            request.NetworkUpdatedAt,
            request.RawPayload);

        try
        {
            var response = await _ingestConversionHandler.HandleAsync(command, cancellationToken);

            return Ok(response);
        }
        catch (ArgumentException exception)
        {
            return BadRequest(new
            {
                message = exception.Message
            });
        }
        catch (InvalidOperationException exception)
        {
            return NotFound(new
            {
                message = exception.Message
            });
        }
        catch (DbUpdateException exception)
            when (exception.InnerException is PostgresException
            {
                SqlState: PostgresErrorCodes.UniqueViolation
            })
        {
            return Conflict(new
            {
                message = "This conversion was ingested concurrently. Retry to update it."
            });
        }
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
