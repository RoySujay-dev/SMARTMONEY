using System.Security.Cryptography;
using SmartMoney.Application.Abstractions.Affiliate;

namespace SmartMoney.Infrastructure.Affiliate;

public sealed class SecureAffiliateTokenGenerator : IAffiliateTokenGenerator
{
    private const int RedirectTokenByteLength = 32;

    public string GenerateTrackingReference()
    {
        return Guid.NewGuid().ToString("N");
    }

    public string GenerateRedirectToken()
    {
        byte[] tokenBytes = RandomNumberGenerator.GetBytes(RedirectTokenByteLength);

        return Convert.ToBase64String(tokenBytes)
            .TrimEnd('=')
            .Replace('+', '-')
            .Replace('/', '_');
    }
}
