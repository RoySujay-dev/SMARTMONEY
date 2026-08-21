using System.Text.RegularExpressions;
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
    public async Task<Offer?> GetActiveByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var currentTime = DateTime.UtcNow;

        return await _dbContext.Offers
            .AsNoTracking()
            .FirstOrDefaultAsync(offer =>
                offer.IsActive &&
                offer.Id == id &&
                (!offer.StartAt.HasValue ||
                    offer.StartAt.Value <= currentTime) &&
                (!offer.EndAt.HasValue ||
                    offer.EndAt.Value >= currentTime),
                cancellationToken);
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

    public async Task<IReadOnlyList<Offer>> SearchAsync(string searchTerm,CancellationToken cancellationToken = default)
    {
        var currentTime = DateTime.UtcNow;
        var pattern = SearchPattern.WordPrefix(searchTerm);

        return await _dbContext.Offers
            .AsNoTracking()
            .Include(offer => offer.Store)
            .Where(offer =>
                offer.IsActive &&
                offer.Store.IsActive &&
                (!offer.StartAt.HasValue || offer.StartAt.Value <= currentTime) &&
                (!offer.EndAt.HasValue || offer.EndAt.Value >= currentTime) &&
                (
                    Regex.IsMatch(offer.Title, pattern, RegexOptions.IgnoreCase) ||
                    Regex.IsMatch(offer.Slug, pattern, RegexOptions.IgnoreCase) ||
                    (
                        offer.ShortDescription != null && Regex.IsMatch(offer.ShortDescription, pattern, RegexOptions.IgnoreCase)
                    ) ||
                    (
                        offer.CashbackText != null && Regex.IsMatch(offer.CashbackText, pattern, RegexOptions.IgnoreCase)
                    ) ||
                    Regex.IsMatch(offer.Store.Name, pattern, RegexOptions.IgnoreCase)
                ))
            .OrderByDescending(offer => offer.IsFeatured)
            .ThenBy(offer => offer.Priority)
            .ThenBy(offer => offer.Title)
            .ToListAsync(cancellationToken);
    }
    public async Task<IReadOnlyList<Offer>> GetActiveByStoreSlugAsync(string storeSlug,CancellationToken cancellationToken = default)
    {
        var currentTime = DateTime.UtcNow;

        return await _dbContext.Offers
            .AsNoTracking()
            .Include(offer => offer.Store)
            .Where(offer =>
                offer.IsActive &&
                offer.Store.IsActive &&
                offer.Store.Slug == storeSlug &&
                (!offer.StartAt.HasValue ||
                    offer.StartAt.Value <= currentTime) &&
                (!offer.EndAt.HasValue ||
                    offer.EndAt.Value >= currentTime))
            .OrderByDescending(offer => offer.IsFeatured)
            .ThenBy(offer => offer.Priority)
            .ThenBy(offer => offer.Title)
            .ToListAsync(cancellationToken);
    }
}