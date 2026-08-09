using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Offers;
using SmartMoney.Application.Features.Offers.GetOffers;
using SmartMoney.Application.Features.Offers.GetOfferDetails;

namespace SmartMoney.Api.Controllers;

[ApiController]
[Route("api/offers")]
public sealed class OffersController : ControllerBase
{
    private readonly IQueryHandler<GetOffersQuery,IReadOnlyList<OfferListItemResponse>> _getOffersHandler;
    private readonly IQueryHandler<GetOfferDetailsQuery,OfferDetailsResponse?> _getOfferDetailsHandler;

    public OffersController(IQueryHandler<GetOffersQuery,IReadOnlyList<OfferListItemResponse>> getOffersHandler, 
                            IQueryHandler<GetOfferDetailsQuery, OfferDetailsResponse?> getOfferDetailsHandler)
    {
        _getOffersHandler = getOffersHandler;
        _getOfferDetailsHandler = getOfferDetailsHandler;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<OfferListItemResponse>),StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<OfferListItemResponse>>> GetAll(CancellationToken cancellationToken)
    {
        var query = new GetOffersQuery();

        var offers = await _getOffersHandler.HandleAsync(query,cancellationToken);

        return Ok(offers);
    }

    [HttpGet("{slug}")]
    [ProducesResponseType(typeof(OfferDetailsResponse),StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<OfferDetailsResponse>> GetBySlug(string slug,CancellationToken cancellationToken)
    {
        var query = new GetOfferDetailsQuery(slug);

        var offer = await _getOfferDetailsHandler.HandleAsync(query,cancellationToken);

        if (offer is null)
        {
            return NotFound();
        }

        return Ok(offer);
    }
}