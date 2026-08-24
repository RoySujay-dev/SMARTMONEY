using SmartMoney.Application.Abstractions.Affiliate;

namespace SmartMoney.Infrastructure.Affiliate;

/// <summary>
/// Stand-in network used until real provider credentials exist. Appends the
/// tracking reference as a <c>subid</c> query parameter so the full loop —
/// tracked redirect out, sub-ID echoed back by the postback simulator — works
/// end-to-end without a provider account.
/// </summary>
public sealed class MockAffiliateNetworkClient : IAffiliateNetworkClient
{
    public Task<string?> BuildTrackedUrlAsync(
        string destinationUrl,
        string trackingReference,
        CancellationToken cancellationToken = default)
    {
        if (!Uri.TryCreate(destinationUrl, UriKind.Absolute, out var uri)
            || (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
        {
            return Task.FromResult<string?>(null);
        }

        var separator = string.IsNullOrEmpty(uri.Query) ? "?" : "&";
        var tracked = $"{destinationUrl}{separator}subid={Uri.EscapeDataString(trackingReference)}";

        return Task.FromResult<string?>(tracked);
    }
}
