namespace SmartMoney.Application.Abstractions.Affiliate;

public interface IAffiliateTokenGenerator
{
    string GenerateTrackingReference();

    string GenerateRedirectToken();
}
