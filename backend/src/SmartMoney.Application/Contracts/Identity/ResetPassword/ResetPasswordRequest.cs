namespace SmartMoney.Application.Contracts.Identity.ResetPassword;

public sealed class ResetPasswordRequest
{
    public string Email { get; set; } = string.Empty;

    public string Otp { get; set; } = string.Empty;

    public string NewPassword { get; set; } = string.Empty;
}
