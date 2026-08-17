using Microsoft.EntityFrameworkCore;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;
using SmartMoney.Infrastructure.Persistence.Context;

namespace SmartMoney.Infrastructure.Persistence.Repositories;

public sealed class StoreAffiliateMappingRepository : IStoreAffiliateMappingRepository
{
    private readonly SmartMoneyDbContext _dbContext;

    public StoreAffiliateMappingRepository(SmartMoneyDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<StoreAffiliateMapping?> GetActiveByStoreIdAsync(Guid storeId, CancellationToken cancellationToken = default)
    {
        return await _dbContext.StoreAffiliateMappings
            .AsNoTracking()
            .Include(mapping => mapping.Store)
            .Include(mapping => mapping.AffiliateNetwork)
            .FirstOrDefaultAsync(mapping =>
                mapping.StoreId == storeId &&
                mapping.IsActive &&
                mapping.Store.IsActive &&
                mapping.AffiliateNetwork.IsActive,
                cancellationToken);
    }
}
