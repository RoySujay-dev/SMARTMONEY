namespace SmartMoney.Application.Contracts.Identity.RefreshToken;

public sealed class RefreshTokenRequest
{
    public string RefreshToken { get; set; } = string.Empty;
}
