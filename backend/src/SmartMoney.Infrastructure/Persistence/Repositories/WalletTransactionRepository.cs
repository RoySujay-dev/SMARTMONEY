using Microsoft.EntityFrameworkCore;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;
using SmartMoney.Infrastructure.Persistence.Context;

namespace SmartMoney.Infrastructure.Persistence.Repositories;

public sealed class WalletTransactionRepository : IWalletTransactionRepository
{
    private readonly SmartMoneyDbContext _context;

    public WalletTransactionRepository(SmartMoneyDbContext context)
    {
        _context = context;
    }

    public async Task AddAsync(
        WalletTransaction transaction,
        CancellationToken cancellationToken = default)
    {
        await _context.WalletTransactions.AddAsync(transaction, cancellationToken);
    }

    public async Task<IReadOnlyList<WalletTransaction>> ListByUserIdAsync(
        Guid userId,
        int page,
        int pageSize,
        CancellationToken cancellationToken = default)
    {
        return await _context.WalletTransactions
            .AsNoTracking()
            .Where(transaction => transaction.UserId == userId)
            .OrderByDescending(transaction => transaction.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);
    }

    public async Task<int> CountByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _context.WalletTransactions
            .CountAsync(
                transaction => transaction.UserId == userId,
                cancellationToken);
    }
}
