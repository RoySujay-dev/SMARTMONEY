namespace SmartMoney.Application.Contracts.Identity.RefreshToken;

public sealed class RefreshTokenResponse
{
    public string AccessToken { get; set; } = string.Empty;

    public DateTime AccessTokenExpiresAt { get; set; }

    public string RefreshToken { get; set; } = string.Empty;
}
