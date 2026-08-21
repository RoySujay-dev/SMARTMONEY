using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface IStoreAffiliateMappingRepository
{
    Task<StoreAffiliateMapping?> GetActiveByStoreIdAsync(Guid storeId, CancellationToken cancellationToken = default);
}
