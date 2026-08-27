using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Wallets;
using SmartMoney.Application.Features.Wallets.GetMyWallet;
using SmartMoney.Application.Features.Wallets.GetMyWalletTransactions;

namespace SmartMoney.Api.Controllers;

[ApiController]
[Authorize]
public sealed class WalletController : ControllerBase
{
    private readonly IQueryHandler<GetMyWalletQuery, MyWalletResponse> _getWalletHandler;
    private readonly IQueryHandler<GetMyWalletTransactionsQuery, WalletTransactionListResponse> _getTransactionsHandler;

    public WalletController(
        IQueryHandler<GetMyWalletQuery, MyWalletResponse> getWalletHandler,
        IQueryHandler<GetMyWalletTransactionsQuery, WalletTransactionListResponse> getTransactionsHandler)
    {
        _getWalletHandler = getWalletHandler;
        _getTransactionsHandler = getTransactionsHandler;
    }

    [HttpGet("api/wallet")]
    [ProducesResponseType(typeof(MyWalletResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<MyWalletResponse>> GetMyWallet(
        CancellationToken cancellationToken)
    {
        string? userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (!Guid.TryParse(userIdClaim, out Guid userId))
        {
            return Unauthorized();
        }

        var response = await _getWalletHandler.HandleAsync(
            new GetMyWalletQuery(userId), cancellationToken);

        return Ok(response);
    }

    [HttpGet("api/wallet/transactions")]
    [ProducesResponseType(typeof(WalletTransactionListResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<WalletTransactionListResponse>> GetMyTransactions(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        string? userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (!Guid.TryParse(userIdClaim, out Guid userId))
        {
            return Unauthorized();
        }

        var response = await _getTransactionsHandler.HandleAsync(
            new GetMyWalletTransactionsQuery(userId, page, pageSize),
            cancellationToken);

        return Ok(response);
    }
}
