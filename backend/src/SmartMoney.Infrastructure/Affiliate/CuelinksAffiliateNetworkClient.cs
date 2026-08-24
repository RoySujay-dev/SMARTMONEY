using Microsoft.Extensions.Options;
using SmartMoney.Application.Abstractions.Affiliate;

namespace SmartMoney.Infrastructure.Affiliate;

/// <summary>
/// Skeleton for the real Cuelinks V3 client. Registered instead of the mock
/// only when an API key is configured. The link-conversion call is left
/// unimplemented on purpose: the request/response contract must be verified
/// against a live Cuelinks account before any code pretends to speak it.
/// </summary>
public sealed class CuelinksAffiliateNetworkClient : IAffiliateNetworkClient
{
    private readonly HttpClient _httpClient;

    public CuelinksAffiliateNetworkClient(
        HttpClient httpClient,
        IOptions<CuelinksOptions> options)
    {
        _httpClient = httpClient;
        _httpClient.BaseAddress = new Uri(options.Value.BaseUrl);

        // Auth scheme per publicly documented Cuelinks V3 convention;
        // verify against the live account before production use.
        _httpClient.DefaultRequestHeaders.TryAddWithoutValidation(
            "Authorization", $"Token {options.Value.ApiKey}");
    }

    public Task<string?> BuildTrackedUrlAsync(
        string destinationUrl,
        string trackingReference,
        CancellationToken cancellationToken = default)
    {
        // Expected shape: POST /links/convert with the destination URL and
        // trackingReference as subid, returning the wrapped deep link.
        throw new NotSupportedException(
            "Cuelinks link conversion is not implemented yet. The API contract " +
            "must be verified against a live Cuelinks account first; run with an " +
            "empty AffiliateNetworks:Cuelinks:ApiKey to use the mock client.");
    }
}
