using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Cashbacks;
using SmartMoney.Application.Features.Cashbacks.ApproveCashback;
using SmartMoney.Application.Features.Cashbacks.ListCashbacks;
using SmartMoney.Application.Features.Cashbacks.RejectCashback;
using SmartMoney.Application.Features.Cashbacks.ReverseCashback;
using SmartMoney.Domain.Enums;

namespace SmartMoney.Api.Controllers;

/// <summary>
/// The human half of the cashback pipeline: automated ingestion only ever
/// parks cashbacks in AwaitingAdminReview; these endpoints move the money.
/// </summary>
[ApiController]
[Authorize(Roles = "Admin,SuperAdmin")]
public sealed class AdminCashbacksController : ControllerBase
{
    private readonly IQueryHandler<ListCashbacksQuery, AdminCashbackListResponse> _listHandler;
    private readonly ICommandHandler<ApproveCashbackCommand, CashbackDecisionResponse?> _approveHandler;
    private readonly ICommandHandler<RejectCashbackCommand, CashbackDecisionResponse?> _rejectHandler;
    private readonly ICommandHandler<ReverseCashbackCommand, CashbackDecisionResponse?> _reverseHandler;

    public AdminCashbacksController(
        IQueryHandler<ListCashbacksQuery, AdminCashbackListResponse> listHandler,
        ICommandHandler<ApproveCashbackCommand, CashbackDecisionResponse?> approveHandler,
        ICommandHandler<RejectCashbackCommand, CashbackDecisionResponse?> rejectHandler,
        ICommandHandler<ReverseCashbackCommand, CashbackDecisionResponse?> reverseHandler)
    {
        _listHandler = listHandler;
        _approveHandler = approveHandler;
        _rejectHandler = rejectHandler;
        _reverseHandler = reverseHandler;
    }

    [HttpGet("api/admin/cashbacks")]
    [ProducesResponseType(typeof(AdminCashbackListResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<ActionResult<AdminCashbackListResponse>> List(
        [FromQuery] string? status = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        CashbackStatus? statusFilter = null;

        if (!string.IsNullOrWhiteSpace(status))
        {
            if (!Enum.TryParse(status.Trim(), ignoreCase: true, out CashbackStatus parsed))
            {
                return BadRequest(new
                {
                    message = "Unknown cashback status. Valid values: "
                        + string.Join(", ", Enum.GetNames<CashbackStatus>()) + "."
                });
            }

            statusFilter = parsed;
        }

        var response = await _listHandler.HandleAsync(
            new ListCashbacksQuery(statusFilter, page, pageSize), cancellationToken);

        return Ok(response);
    }

    [HttpPost("api/admin/cashbacks/{id:guid}/approve")]
    [ProducesResponseType(typeof(CashbackDecisionResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public Task<ActionResult<CashbackDecisionResponse>> Approve(
        Guid id,
        CancellationToken cancellationToken)
    {
        return DecideAsync(
            () => _approveHandler.HandleAsync(
                new ApproveCashbackCommand(id), cancellationToken));
    }

    [HttpPost("api/admin/cashbacks/{id:guid}/reject")]
    [ProducesResponseType(typeof(CashbackDecisionResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public Task<ActionResult<CashbackDecisionResponse>> Reject(
        Guid id,
        CancellationToken cancellationToken)
    {
        return DecideAsync(
            () => _rejectHandler.HandleAsync(
                new RejectCashbackCommand(id), cancellationToken));
    }

    [HttpPost("api/admin/cashbacks/{id:guid}/reverse")]
    [ProducesResponseType(typeof(CashbackDecisionResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public Task<ActionResult<CashbackDecisionResponse>> Reverse(
        Guid id,
        CancellationToken cancellationToken)
    {
        return DecideAsync(
            () => _reverseHandler.HandleAsync(
                new ReverseCashbackCommand(id), cancellationToken));
    }

    private async Task<ActionResult<CashbackDecisionResponse>> DecideAsync(
        Func<Task<CashbackDecisionResponse?>> decision)
    {
        try
        {
            var response = await decision();

            if (response is null)
            {
                return NotFound(new { message = "Cashback not found." });
            }

            return Ok(response);
        }
        catch (InvalidOperationException exception)
        {
            return Conflict(new { message = exception.Message });
        }
    }
}
