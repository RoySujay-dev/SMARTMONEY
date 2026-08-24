using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Abstractions.Persistence;

public interface IRefreshTokenRepository
{
    Task<RefreshToken?> GetByTokenAsync(
        string token,
        CancellationToken cancellationToken = default);

    Task AddAsync(
        RefreshToken refreshToken,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Revokes every non-revoked token for the user. Called on password
    /// reset so a device that had a valid refresh token before the reset
    /// cannot stay signed in after it.
    /// </summary>
    Task RevokeAllForUserAsync(
        Guid userId,
        CancellationToken cancellationToken = default);
}
