using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Stores;
using SmartMoney.Application.Features.Stores.GetStores;
using SmartMoney.Application.Features.Stores.GetStoreDetails;

namespace SmartMoney.Api.Controllers;

[ApiController]
[Route("api/stores")]
public sealed class StoresController : ControllerBase

{
    private readonly IQueryHandler <GetStoresQuery,IReadOnlyList <StoreListItemResponse>> _getStoresHandler;

    private readonly IQueryHandler <GetStoreDetailsQuery, StoreDetailsResponse?> _getStoreDetailsHandler;
    public StoresController (IQueryHandler<GetStoresQuery,IReadOnlyList<StoreListItemResponse>> getStoresHandler,
                             IQueryHandler<GetStoreDetailsQuery,StoreDetailsResponse?> getStoreDetailsHandler)
    {
        _getStoresHandler = getStoresHandler;
        _getStoreDetailsHandler = getStoreDetailsHandler;
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

        var store = await _getStoreDetailsHandler.HandleAsync(
            query,
            cancellationToken);

        if (store is null)
        {
            return NotFound();
        }

        return Ok(store);
    }
}