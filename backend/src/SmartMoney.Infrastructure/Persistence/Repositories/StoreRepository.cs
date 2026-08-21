using System.Text.RegularExpressions;
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
    public async Task <IReadOnlyList<Store>> GetActiveByCategorySlugAsync (string categorySlug, CancellationToken cancellationToken = default)

    {
        return await _dbContext.Stores
            .AsNoTracking()
            .Where(store =>
                store.IsActive &&
                store.StoreCategories.Any(storeCategory =>
                    storeCategory.Category.IsActive &&
                    storeCategory.Category.Slug == categorySlug))
            .OrderBy(store => store.DisplayOrder)
            .ThenBy(store => store.Name)
            .ToListAsync(cancellationToken);
    }
    public async Task<Store?> GetActiveBySlugAsync (string slug, CancellationToken cancellationToken = default)

    {
        return await _dbContext.Stores
            .AsNoTracking()
            .FirstOrDefaultAsync (store => store.IsActive && store.Slug == slug, cancellationToken);
    }
    public async Task<IReadOnlyList<Store>> SearchAsync(string searchTerm, CancellationToken cancellationToken = default)
    {
        var pattern = SearchPattern.WordPrefix(searchTerm);

        return await _dbContext.Stores
            .AsNoTracking()
            .Where(store => store.IsActive &&
                (
                    Regex.IsMatch(store.Name, pattern, RegexOptions.IgnoreCase) ||
                    Regex.IsMatch(store.Slug, pattern, RegexOptions.IgnoreCase) ||
                    (
                        store.ShortDescription != null && Regex.IsMatch(store.ShortDescription, pattern, RegexOptions.IgnoreCase)
                    )
                ))
            .OrderBy(store => store.DisplayOrder)
            .ThenBy(store => store.Name)
            .ToListAsync(cancellationToken);
    }
}