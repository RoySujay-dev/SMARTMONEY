using Microsoft.EntityFrameworkCore;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;
using SmartMoney.Infrastructure.Persistence.Context;

namespace SmartMoney.Infrastructure.Persistence.Repositories;

public sealed class PasswordResetOtpRepository : IPasswordResetOtpRepository
{
    private readonly SmartMoneyDbContext _context;

    public PasswordResetOtpRepository(SmartMoneyDbContext context)
    {
        _context = context;
    }

    public async Task AddAsync(
        PasswordResetOtp passwordResetOtp,
        CancellationToken cancellationToken = default)
    {
        await _context.PasswordResetOtps.AddAsync(passwordResetOtp, cancellationToken);
    }

    public Task<PasswordResetOtp?> GetLatestValidByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        DateTime currentTime = DateTime.UtcNow;

        return _context.PasswordResetOtps
            .Where(otp =>
                otp.UserId == userId &&
                !otp.IsUsed &&
                otp.ExpiresAt > currentTime)
            .OrderByDescending(otp => otp.ExpiresAt)
            .FirstOrDefaultAsync(cancellationToken);
    }
}
