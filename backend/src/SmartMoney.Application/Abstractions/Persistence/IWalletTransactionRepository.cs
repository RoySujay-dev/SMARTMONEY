using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface IWalletTransactionRepository
{
    Task AddAsync(
        WalletTransaction transaction,
        CancellationToken cancellationToken = default);

    /// <summary>Newest first. Read-only (no change tracking).</summary>
    Task<IReadOnlyList<WalletTransaction>> ListByUserIdAsync(
        Guid userId,
        int page,
        int pageSize,
        CancellationToken cancellationToken = default);

    Task<int> CountByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default);
}
