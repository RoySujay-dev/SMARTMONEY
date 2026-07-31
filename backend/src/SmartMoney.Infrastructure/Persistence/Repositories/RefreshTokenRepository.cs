using Microsoft.EntityFrameworkCore;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;
using SmartMoney.Infrastructure.Persistence.Context;

namespace SmartMoney.Infrastructure.Persistence.Repositories;

public sealed class RefreshTokenRepository : IRefreshTokenRepository
{
    private readonly SmartMoneyDbContext _context;

    public RefreshTokenRepository(SmartMoneyDbContext context)
    {
        _context = context;
    }

    public Task<RefreshToken?> GetByTokenAsync(
        string token,
        CancellationToken cancellationToken = default)
    {
        return _context.RefreshTokens
            .Include(refreshToken => refreshToken.User)
            .ThenInclude(user => user.Role)
            .SingleOrDefaultAsync(
                refreshToken => refreshToken.Token == token,
                cancellationToken);
    }

    public async Task AddAsync(
        RefreshToken refreshToken,
        CancellationToken cancellationToken = default)
    {
        await _context.RefreshTokens.AddAsync(refreshToken, cancellationToken);
    }
}
