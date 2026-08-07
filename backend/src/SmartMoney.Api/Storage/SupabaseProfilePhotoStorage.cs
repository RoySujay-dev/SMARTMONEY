using System.Net.Http.Headers;
using Microsoft.Extensions.Options;

namespace SmartMoney.Api.Storage;

public sealed class SupabaseProfilePhotoStorage : IProfilePhotoStorage
{
    private readonly HttpClient _httpClient;
    private readonly SupabaseStorageOptions _options;
    private readonly ILogger<SupabaseProfilePhotoStorage> _logger;

    public SupabaseProfilePhotoStorage(
        HttpClient httpClient,
        IOptions<SupabaseStorageOptions> options,
        ILogger<SupabaseProfilePhotoStorage> logger)
    {
        _httpClient = httpClient;
        _options = options.Value;
        _logger = logger;
    }

    public async Task<StoredProfilePhoto> UploadAsync(
        Stream content,
        string objectPath,
        string contentType,
        CancellationToken cancellationToken)
    {
        ValidateOptions();

        string normalizedPath = NormalizeObjectPath(objectPath);
        Uri uploadUri = BuildObjectUri(normalizedPath, isPublic: false);

        using var request = new HttpRequestMessage(HttpMethod.Post, uploadUri);
        AddAuthenticationHeaders(request);
        request.Headers.TryAddWithoutValidation(
            "cache-control",
            _options.CacheControlSeconds.ToString());

        request.Content = new StreamContent(content);
        request.Content.Headers.ContentType =
            MediaTypeHeaderValue.Parse(contentType);

        using HttpResponseMessage response =
            await _httpClient.SendAsync(request, cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            string responseBody =
                await response.Content.ReadAsStringAsync(cancellationToken);

            throw new InvalidOperationException(
                "Supabase profile photo upload failed with status " +
                $"{(int)response.StatusCode}: {responseBody}");
        }

        return new StoredProfilePhoto(
            BuildObjectUri(normalizedPath, isPublic: true).ToString(),
            normalizedPath);
    }

    public async Task DeleteByPublicUrlAsync(
        string? publicUrl,
        CancellationToken cancellationToken)
    {
        if (!TryGetObjectPath(publicUrl, out string? objectPath) ||
            objectPath is null)
        {
            return;
        }

        try
        {
            using var request = new HttpRequestMessage(
                HttpMethod.Delete,
                BuildObjectUri(objectPath, isPublic: false));

            AddAuthenticationHeaders(request);

            using HttpResponseMessage response =
                await _httpClient.SendAsync(request, cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                string responseBody =
                    await response.Content.ReadAsStringAsync(cancellationToken);

                _logger.LogWarning(
                    "Supabase profile photo delete failed with status {Status}: {Body}",
                    (int)response.StatusCode,
                    responseBody);
            }
        }
        catch (Exception exception)
        {
            _logger.LogWarning(
                exception,
                "Supabase profile photo cleanup failed.");
        }
    }

    private void AddAuthenticationHeaders(HttpRequestMessage request)
    {
        request.Headers.TryAddWithoutValidation(
            "apikey",
            _options.ServiceRoleKey);

        request.Headers.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            _options.ServiceRoleKey);
    }

    private Uri BuildObjectUri(string objectPath, bool isPublic)
    {
        string encodedPath = string.Join(
            "/",
            objectPath
                .Split('/', StringSplitOptions.RemoveEmptyEntries)
                .Select(Uri.EscapeDataString));

        string visibilitySegment = isPublic ? "/public" : string.Empty;
        string url = _options.Url.TrimEnd('/');

        return new Uri(
            $"{url}/storage/v1/object{visibilitySegment}/" +
            $"{Uri.EscapeDataString(_options.Bucket)}/{encodedPath}");
    }

    private bool TryGetObjectPath(string? publicUrl, out string? objectPath)
    {
        objectPath = null;

        if (string.IsNullOrWhiteSpace(publicUrl))
        {
            return false;
        }

        ValidateOptions();

        string publicPrefix =
            $"{_options.Url.TrimEnd('/')}/storage/v1/object/public/" +
            $"{Uri.EscapeDataString(_options.Bucket)}/";

        if (!publicUrl.StartsWith(
                publicPrefix,
                StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        objectPath = Uri.UnescapeDataString(publicUrl[publicPrefix.Length..]);
        return !string.IsNullOrWhiteSpace(objectPath);
    }

    private void ValidateOptions()
    {
        if (string.IsNullOrWhiteSpace(_options.Url))
        {
            throw new InvalidOperationException(
                "Supabase Storage URL is not configured.");
        }

        if (string.IsNullOrWhiteSpace(_options.ServiceRoleKey))
        {
            throw new InvalidOperationException(
                "Supabase Storage service role key is not configured.");
        }

        if (string.IsNullOrWhiteSpace(_options.Bucket))
        {
            throw new InvalidOperationException(
                "Supabase Storage bucket is not configured.");
        }
    }

    private static string NormalizeObjectPath(string objectPath)
    {
        string normalized = objectPath.Trim().Replace('\\', '/');

        if (string.IsNullOrWhiteSpace(normalized))
        {
            throw new ArgumentException(
                "Object path is required.",
                nameof(objectPath));
        }

        return normalized.TrimStart('/');
    }
}
