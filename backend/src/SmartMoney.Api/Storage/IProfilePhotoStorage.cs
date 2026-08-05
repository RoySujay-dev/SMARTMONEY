namespace SmartMoney.Api.Storage;

public interface IProfilePhotoStorage
{
    Task<StoredProfilePhoto> UploadAsync(
        Stream content,
        string objectPath,
        string contentType,
        CancellationToken cancellationToken);

    Task DeleteByPublicUrlAsync(
        string? publicUrl,
        CancellationToken cancellationToken);
}

public sealed record StoredProfilePhoto(
    string PublicUrl,
    string ObjectPath);
