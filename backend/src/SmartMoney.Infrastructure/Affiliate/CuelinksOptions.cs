namespace SmartMoney.Infrastructure.Affiliate;

public sealed class CuelinksOptions
{
    public const string SectionName = "AffiliateNetworks:Cuelinks";

    /// <summary>
    /// Empty (the default) keeps the mock network client registered; setting a
    /// key switches DI to <see cref="CuelinksAffiliateNetworkClient"/>. Comes
    /// from User Secrets, never from a tracked config file.
    /// </summary>
    public string ApiKey { get; init; } = string.Empty;

    public string BaseUrl { get; init; } = "https://www.cuelinks.com/api/v3";
}
