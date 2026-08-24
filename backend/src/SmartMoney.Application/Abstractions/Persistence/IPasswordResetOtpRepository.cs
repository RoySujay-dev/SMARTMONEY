using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface IPasswordResetOtpRepository
{
    Task AddAsync(
        PasswordResetOtp passwordResetOtp,
        CancellationToken cancellationToken = default);

    Task<PasswordResetOtp?> GetLatestValidByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default);
}
