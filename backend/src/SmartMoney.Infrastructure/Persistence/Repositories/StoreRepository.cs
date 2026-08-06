using Microsoft.EntityFrameworkCore;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;
using SmartMoney.Infrastructure.Persistence.Context;

namespace SmartMoney.Infrastructure.Persistence.Repositories;

public sealed class StoreRepository : IStoreRepository
{
    private readonly SmartMoneyDbContext _dbContext;

    public StoreRepository(SmartMoneyDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<Store>> GetActiveAsync(CancellationToken cancellationToken = default)
    {
        return await _dbContext.Stores
            .AsNoTracking()
            .Where(store => store.IsActive)
            .OrderBy(store => store.DisplayOrder)
            .ThenBy(store => store.Name)
            .ToListAsync(cancellationToken);
    }
}