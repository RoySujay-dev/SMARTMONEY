using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface IAffiliateNetworkRepository
{
    /// <summary>
    /// Resolves a network by its code regardless of <c>IsActive</c>:
    /// inbound conversions must not be dropped because a network is paused.
    /// </summary>
    Task<AffiliateNetwork?> GetByCodeAsync(string code, CancellationToken cancellationToken = default);
}
