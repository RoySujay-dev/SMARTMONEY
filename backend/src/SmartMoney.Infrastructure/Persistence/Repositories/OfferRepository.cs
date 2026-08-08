using Microsoft.EntityFrameworkCore;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;
using SmartMoney.Infrastructure.Persistence.Context;

namespace SmartMoney.Infrastructure.Persistence.Repositories;

public sealed class OfferRepository : IOfferRepository
{
    private readonly SmartMoneyDbContext _dbContext;

    public OfferRepository(SmartMoneyDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<Offer>> GetActiveAsync(CancellationToken cancellationToken = default)
    {
        var currentTime = DateTime.UtcNow;

        return await _dbContext.Offers
            .AsNoTracking()
            .Include(offer => offer.Store)
            .Where(offer =>
                offer.IsActive &&
                offer.Store.IsActive &&
                (!offer.StartAt.HasValue ||
                    offer.StartAt.Value <= currentTime) &&
                (!offer.EndAt.HasValue ||
                    offer.EndAt.Value >= currentTime))
            .OrderByDescending(offer => offer.IsFeatured)
            .ThenBy(offer => offer.Priority)
            .ThenBy(offer => offer.Title)
            .ToListAsync(cancellationToken);
    }
    public async Task<Offer?> GetActiveBySlugAsync(string slug,CancellationToken cancellationToken = default)
    {
        var currentTime = DateTime.UtcNow;

        return await _dbContext.Offers
            .AsNoTracking()
            .Include(offer => offer.Store)
            .FirstOrDefaultAsync(
                offer =>
                    offer.IsActive &&
                    offer.Store.IsActive &&
                    offer.Slug == slug &&
                    (!offer.StartAt.HasValue ||
                        offer.StartAt.Value <= currentTime) &&
                    (!offer.EndAt.HasValue ||
                        offer.EndAt.Value >= currentTime),
                cancellationToken);
    }
}