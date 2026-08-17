using Microsoft.EntityFrameworkCore;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;
using SmartMoney.Infrastructure.Persistence.Context;

namespace SmartMoney.Infrastructure.Persistence.Repositories;

public sealed class AffiliateNetworkRepository : IAffiliateNetworkRepository
{
    private readonly SmartMoneyDbContext _dbContext;

    public AffiliateNetworkRepository(SmartMoneyDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<AffiliateNetwork?> GetByCodeAsync(string code, CancellationToken cancellationToken = default)
    {
        return await _dbContext.AffiliateNetworks
            .AsNoTracking()
            .FirstOrDefaultAsync(
                network => network.Code == code,
                cancellationToken);
    }
}
