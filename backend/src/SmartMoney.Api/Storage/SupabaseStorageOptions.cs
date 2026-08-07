namespace SmartMoney.Api.Storage;

public sealed class SupabaseStorageOptions
{
    public const string SectionName = "SupabaseStorage";

    public string Url { get; init; } = string.Empty;

    public string ServiceRoleKey { get; init; } = string.Empty;

    public string Bucket { get; init; } = "profile-images";

    public int CacheControlSeconds { get; init; } = 3600;
}
