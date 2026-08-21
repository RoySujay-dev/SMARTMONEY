using Microsoft.EntityFrameworkCore;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;
using SmartMoney.Infrastructure.Persistence.Context;

namespace SmartMoney.Infrastructure.Persistence.Repositories;

public sealed class AffiliateConversionRepository : IAffiliateConversionRepository
{
    private readonly SmartMoneyDbContext _dbContext;

    public AffiliateConversionRepository(SmartMoneyDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task AddAsync(AffiliateConversion conversion, CancellationToken cancellationToken = default)
    {
        await _dbContext.AffiliateConversions.AddAsync(conversion, cancellationToken);
    }

    // Tracked: the ingestion handler mutates the returned entity and saves.
    public async Task<AffiliateConversion?> GetByNetworkAndTransactionIdAsync(
        Guid affiliateNetworkId,
        string networkTransactionId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.AffiliateConversions
            .FirstOrDefaultAsync(
                conversion =>
                    conversion.AffiliateNetworkId == affiliateNetworkId &&
                    conversion.NetworkTransactionId == networkTransactionId,
                cancellationToken);
    }
}
