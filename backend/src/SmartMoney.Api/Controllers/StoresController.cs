using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Offers;
using SmartMoney.Application.Contracts.Stores;
using SmartMoney.Application.Features.Stores.GetStoreDetails;
using SmartMoney.Application.Features.Stores.GetStoreOffers;
using SmartMoney.Application.Features.Stores.GetStores;

namespace SmartMoney.Api.Controllers;

[ApiController]
[Route("api/stores")]
public sealed class StoresController : ControllerBase

{ 
    private readonly IQueryHandler <GetStoresQuery,IReadOnlyList <StoreListItemResponse>> _getStoresHandler;
    private readonly IQueryHandler <GetStoreDetailsQuery, StoreDetailsResponse?> _getStoreDetailsHandler;
    private readonly IQueryHandler<GetStoreOffersQuery,IReadOnlyList<OfferListItemResponse>> _getStoreOffersHandler;
    public StoresController (IQueryHandler<GetStoresQuery,IReadOnlyList<StoreListItemResponse>> getStoresHandler,
                             IQueryHandler<GetStoreDetailsQuery,StoreDetailsResponse?> getStoreDetailsHandler, 
                             IQueryHandler<GetStoreOffersQuery,IReadOnlyList<OfferListItemResponse>> getStoreOffersHandler)
    {
        _getStoresHandler = getStoresHandler;
        _getStoreDetailsHandler = getStoreDetailsHandler;
        _getStoreOffersHandler = getStoreOffersHandler;
    }

    [HttpGet]
    [ProducesResponseType (typeof(IReadOnlyList<StoreListItemResponse>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<StoreListItemResponse>>> GetAll (CancellationToken cancellationToken)

    {
        var query = new GetStoresQuery();

        var stores = await _getStoresHandler.HandleAsync (query,cancellationToken);

        return Ok(stores);
    }

    [HttpGet("{slug}")]
    [ProducesResponseType(typeof(StoreDetailsResponse),StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<StoreDetailsResponse>> GetBySlug(string slug,CancellationToken cancellationToken)

    {
        var query = new GetStoreDetailsQuery(slug);

        var store = await _getStoreDetailsHandler.HandleAsync(query,cancellationToken);

        if (store is null)
        {
            return NotFound();
        }

        return Ok(store);
    }

    [HttpGet("{slug}/offers")]
    [ProducesResponseType(typeof(IReadOnlyList<OfferListItemResponse>),StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<OfferListItemResponse>>> GetOffers(string slug,CancellationToken cancellationToken)
    {
        var query = new GetStoreOffersQuery(slug);

        var offers = await _getStoreOffersHandler.HandleAsync(query,cancellationToken);

        return Ok(offers);
    }
}