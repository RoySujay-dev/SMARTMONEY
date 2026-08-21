using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface IOfferRepository
{
    Task<IReadOnlyList<Offer>> GetActiveAsync(CancellationToken cancellationToken = default);
    Task<Offer?> GetActiveBySlugAsync(string slug, CancellationToken cancellationToken = default);
    Task<Offer?> GetActiveByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Offer>> SearchAsync(string searchTerm, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Offer>> GetActiveByStoreSlugAsync(string storeSlug,CancellationToken cancellationToken = default);
}