namespace SmartMoney.Application.Contracts.Identity.ResetPassword;

public sealed class ResetPasswordResponse
{
    public string Email { get; set; } = string.Empty;

    public string Message { get; set; } = string.Empty;
}
