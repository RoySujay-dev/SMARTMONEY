using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Offers;
using SmartMoney.Application.Features.Offers.GetOffers;

namespace SmartMoney.Api.Controllers;

[ApiController]
[Route("api/offers")]
public sealed class OffersController : ControllerBase
{
    private readonly IQueryHandler<GetOffersQuery,IReadOnlyList<OfferListItemResponse>> _getOffersHandler;
    public OffersController(IQueryHandler<GetOffersQuery,IReadOnlyList<OfferListItemResponse>> getOffersHandler)
    {
        _getOffersHandler = getOffersHandler;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<OfferListItemResponse>),StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<OfferListItemResponse>>> GetAll(CancellationToken cancellationToken)
    {
        var query = new GetOffersQuery();

        var offers = await _getOffersHandler.HandleAsync(query,cancellationToken);

        return Ok(offers);
    }
}