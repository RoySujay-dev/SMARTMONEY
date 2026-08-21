namespace SmartMoney.Application.Contracts.Affiliate;

public sealed record CreateAffiliateClickResponse(
    Guid ClickId,
    string RedirectToken,
    string RedirectPath);
