using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface ICashbackRepository
{
    Task AddAsync(Cashback cashback, CancellationToken cancellationToken = default);

    /// <summary>
    /// Looks up the cashback attached to a conversion. Returned entity is
    /// change-tracked so callers can transition its status and save.
    /// </summary>
    Task<Cashback?> GetByConversionIdAsync(
        Guid affiliateConversionId,
        CancellationToken cancellationToken = default);
}
