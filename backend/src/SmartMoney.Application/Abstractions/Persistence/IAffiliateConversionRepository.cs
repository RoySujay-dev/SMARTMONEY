using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface IAffiliateConversionRepository
{
    Task AddAsync(AffiliateConversion conversion, CancellationToken cancellationToken = default);

    /// <summary>
    /// Looks up a conversion by its idempotency key. Returned entity is
    /// change-tracked so callers can mutate and save.
    /// </summary>
    Task<AffiliateConversion?> GetByNetworkAndTransactionIdAsync(
        Guid affiliateNetworkId,
        string networkTransactionId,
        CancellationToken cancellationToken = default);
}
