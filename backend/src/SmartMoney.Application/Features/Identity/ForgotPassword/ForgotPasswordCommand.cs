using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Identity.ForgotPassword;

namespace SmartMoney.Application.Features.Identity.ForgotPassword;

public sealed class ForgotPasswordCommand : ICommand<ForgotPasswordResponse>
{
    public string Email { get; }

    public ForgotPasswordCommand(string email)
    {
        Email = email;
    }
}
