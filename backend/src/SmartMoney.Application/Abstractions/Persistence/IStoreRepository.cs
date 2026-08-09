using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface IStoreRepository
{
    Task<IReadOnlyList<Store>> GetActiveAsync (CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Store>> GetActiveByCategorySlugAsync (string categorySlug, CancellationToken cancellationToken = default);
    Task<Store?> GetActiveBySlugAsync (string slug, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Store>> SearchAsync(string searchTerm, CancellationToken cancellationToken = default);
}