using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface IOfferRepository
{
    Task<IReadOnlyList<Offer>> GetActiveAsync(CancellationToken cancellationToken = default);
}