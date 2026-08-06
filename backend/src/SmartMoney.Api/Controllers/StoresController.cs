using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Stores;
using SmartMoney.Application.Features.Stores.GetStores;

namespace SmartMoney.Api.Controllers;

[ApiController]
[Route("api/stores")]
public sealed class StoresController : ControllerBase

{
    private readonly IQueryHandler <GetStoresQuery,IReadOnlyList <StoreListItemResponse>> _getStoresHandler;
    public StoresController (IQueryHandler <GetStoresQuery,IReadOnlyList <StoreListItemResponse>> getStoresHandler)

    {
        _getStoresHandler = getStoresHandler;
    }

    [HttpGet]
    [ProducesResponseType (typeof(IReadOnlyList<StoreListItemResponse>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<StoreListItemResponse>>> GetAll (CancellationToken cancellationToken)

    {
        var query = new GetStoresQuery();

        var stores = await _getStoresHandler.HandleAsync (query,cancellationToken);

        return Ok(stores);
    }
}