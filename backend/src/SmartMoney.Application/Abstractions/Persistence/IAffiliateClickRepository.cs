using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface IAffiliateClickRepository
{
    Task AddAsync(AffiliateClick click, CancellationToken cancellationToken = default);

    Task<AffiliateClick?> GetByRedirectTokenAsync(string redirectToken, CancellationToken cancellationToken = default);
}
