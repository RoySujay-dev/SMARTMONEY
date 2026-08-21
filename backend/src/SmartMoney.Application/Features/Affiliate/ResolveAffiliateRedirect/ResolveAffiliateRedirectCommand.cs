using SmartMoney.Application.Abstractions.Messaging;

namespace SmartMoney.Application.Features.Affiliate.ResolveAffiliateRedirect;

public sealed class ResolveAffiliateRedirectCommand : ICommand<string?>
{
    public string RedirectToken { get; }

    public ResolveAffiliateRedirectCommand(string redirectToken)
    {
        RedirectToken = redirectToken;
    }
}
