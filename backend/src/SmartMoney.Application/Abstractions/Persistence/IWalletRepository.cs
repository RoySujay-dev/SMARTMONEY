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

    /// <summary>
    /// Change-tracked — admin decision handlers load by Cashback.WalletId to
    /// mutate balances and save.
    /// </summary>
    Task<Wallet?> GetByIdAsync(
        Guid id,
        CancellationToken cancellationToken = default);
}