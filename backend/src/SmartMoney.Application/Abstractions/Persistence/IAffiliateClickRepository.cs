using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface IAffiliateClickRepository
{
    Task<AffiliateClick?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);

    Task AddAsync(AffiliateClick click, CancellationToken cancellationToken = default);

    Task<AffiliateClick?> GetByRedirectTokenAsync(string redirectToken, CancellationToken cancellationToken = default);

    Task<AffiliateClick?> GetByTrackingReferenceAsync(string trackingReference, CancellationToken cancellationToken = default);
}
