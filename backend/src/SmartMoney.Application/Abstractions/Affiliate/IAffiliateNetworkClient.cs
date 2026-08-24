namespace SmartMoney.Application.Abstractions.Affiliate;

/// <summary>
/// Provider-facing operations for an affiliate network. Implementations are
/// per-provider (Cuelinks, mock); everything upstream of this interface is
/// provider-neutral.
/// </summary>
public interface IAffiliateNetworkClient
{
    /// <summary>
    /// Wraps a merchant destination in the network's tracked deep link,
    /// embedding <paramref name="trackingReference"/> as the sub-ID so the
    /// network echoes it back on conversions. Returns null when the URL
    /// cannot be converted (not affiliated, provider error) — callers fall
    /// back to the untracked destination.
    /// </summary>
    Task<string?> BuildTrackedUrlAsync(
        string destinationUrl,
        string trackingReference,
        CancellationToken cancellationToken = default);
}
