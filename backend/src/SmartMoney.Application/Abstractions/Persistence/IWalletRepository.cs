using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface IWalletRepository
{
    Task AddAsync(
        Wallet wallet,
        CancellationToken cancellationToken = default);

    Task<Wallet?> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default);
}