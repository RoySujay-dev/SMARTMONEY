using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Identity.ResetPassword;

namespace SmartMoney.Application.Features.Identity.ResetPassword;

public sealed class ResetPasswordCommand : ICommand<ResetPasswordResponse>
{
    public string Email { get; }

    public string Otp { get; }

    public string NewPassword { get; }

    public ResetPasswordCommand(string email, string otp, string newPassword)
    {
        Email = email;
        Otp = otp;
        NewPassword = newPassword;
    }
}
