using Microsoft.EntityFrameworkCore;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;
using SmartMoney.Infrastructure.Persistence.Context;

namespace SmartMoney.Infrastructure.Persistence.Repositories;

public sealed class AffiliateClickRepository : IAffiliateClickRepository
{
    private readonly SmartMoneyDbContext _dbContext;

    public AffiliateClickRepository(SmartMoneyDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task AddAsync(AffiliateClick click, CancellationToken cancellationToken = default)
    {
        await _dbContext.AffiliateClicks.AddAsync(click, cancellationToken);
    }

    public async Task<AffiliateClick?> GetByRedirectTokenAsync(string redirectToken, CancellationToken cancellationToken = default)
    {
        return await _dbContext.AffiliateClicks
            .FirstOrDefaultAsync(
                click => click.RedirectToken == redirectToken,
                cancellationToken);
    }
}
