using Microsoft.EntityFrameworkCore;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;
using SmartMoney.Infrastructure.Persistence.Context;

namespace SmartMoney.Infrastructure.Persistence.Repositories;

public sealed class CashbackRepository : ICashbackRepository
{
    private readonly SmartMoneyDbContext _context;

    public CashbackRepository(SmartMoneyDbContext context)
    {
        _context = context;
    }

    public async Task AddAsync(Cashback cashback, CancellationToken cancellationToken = default)
    {
        await _context.Cashbacks.AddAsync(cashback, cancellationToken);
    }

    public async Task<Cashback?> GetByConversionIdAsync(
        Guid affiliateConversionId,
        CancellationToken cancellationToken = default)
    {
        return await _context.Cashbacks
            .FirstOrDefaultAsync(
                cashback => cashback.AffiliateConversionId == affiliateConversionId,
                cancellationToken);
    }
}
