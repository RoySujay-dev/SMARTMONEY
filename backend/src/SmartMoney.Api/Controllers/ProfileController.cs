using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartMoney.Application.Abstractions.Authentication;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/profile")]
public sealed class ProfileController : ControllerBase
{
    private const long MaxProfilePhotoBytes = 2 * 1024 * 1024;

    private static readonly IReadOnlyDictionary<string, string>
        ProfilePhotoExtensions = new Dictionary<string, string>(
            StringComparer.OrdinalIgnoreCase)
        {
            ["image/jpeg"] = ".jpg",
            ["image/png"] = ".png",
            ["image/webp"] = ".webp"
        };

    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IWebHostEnvironment _environment;

    public ProfileController(
        IUserRepository userRepository,
        IPasswordHasher passwordHasher,
        IUnitOfWork unitOfWork,
        IWebHostEnvironment environment)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
        _unitOfWork = unitOfWork;
        _environment = environment;
    }

    [HttpGet]
    [ProducesResponseType(typeof(ProfileResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetProfile(
        CancellationToken cancellationToken)
    {
        User? user = await GetCurrentUserAsync(cancellationToken);

        if (user is null)
        {
            return NotFound(new
            {
                message = "Profile was not found."
            });
        }

        return Ok(ProfileResponse.FromUser(user));
    }

    [HttpPut("update-name")]
    [ProducesResponseType(typeof(ProfileResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateName(
        [FromBody] UpdateProfileNameRequest request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
        {
            return BadRequest(new
            {
                message = "Name is required."
            });
        }

        User? user = await GetCurrentUserAsync(cancellationToken);

        if (user is null)
        {
            return NotFound(new
            {
                message = "Profile was not found."
            });
        }

        user.UpdateFullName(request.Name);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Ok(ProfileResponse.FromUser(user));
    }

    [HttpPut("change-password")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ChangePassword(
        [FromBody] ChangeProfilePasswordRequest request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.NewPassword))
        {
            return BadRequest(new
            {
                message = "Password is required."
            });
        }

        User? user = await GetCurrentUserAsync(cancellationToken);

        if (user is null)
        {
            return NotFound(new
            {
                message = "Profile was not found."
            });
        }

        string passwordHash = _passwordHasher.Hash(request.NewPassword);

        user.ChangePasswordHash(passwordHash);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Ok(new
        {
            message = "Password updated."
        });
    }

    [HttpPost("photo")]
    [Consumes("multipart/form-data")]
    [ProducesResponseType(typeof(ProfileResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UploadPhoto(
        [FromForm] UploadProfilePhotoRequest request,
        CancellationToken cancellationToken)
    {
        IFormFile? photo = request.Photo;

        if (photo is null || photo.Length == 0)
        {
            return BadRequest(new
            {
                message = "Profile photo is required."
            });
        }

        if (photo.Length > MaxProfilePhotoBytes)
        {
            return BadRequest(new
            {
                message = "Profile photo must be 2 MB or smaller."
            });
        }

        string contentType = photo.ContentType ?? string.Empty;

        if (!ProfilePhotoExtensions.TryGetValue(
                contentType,
                out string? extension) ||
            string.IsNullOrWhiteSpace(extension))
        {
            return BadRequest(new
            {
                message = "Only JPG, PNG, and WebP images are supported."
            });
        }

        User? user = await GetCurrentUserAsync(cancellationToken);

        if (user is null)
        {
            return NotFound(new
            {
                message = "Profile was not found."
            });
        }

        string uploadsPath = Path.Combine(
            _environment.WebRootPath ??
            Path.Combine(_environment.ContentRootPath, "wwwroot"),
            "uploads",
            "profile-images");

        Directory.CreateDirectory(uploadsPath);

        string fileName = $"{user.Id:N}-{Guid.NewGuid():N}{extension}";
        string filePath = Path.Combine(uploadsPath, fileName);
        string profileImageUrl = $"/uploads/profile-images/{fileName}";
        string? previousProfileImageUrl = user.ProfileImageUrl;

        await using (FileStream stream = System.IO.File.Create(filePath))
        {
            await photo.CopyToAsync(stream, cancellationToken);
        }

        user.UpdateProfileImageUrl(profileImageUrl);

        try
        {
            await _unitOfWork.SaveChangesAsync(cancellationToken);
        }
        catch
        {
            TryDeleteFile(filePath);
            throw;
        }

        TryDeleteExistingProfilePhoto(previousProfileImageUrl);

        return Ok(ProfileResponse.FromUser(user));
    }

    private async Task<User?> GetCurrentUserAsync(
        CancellationToken cancellationToken)
    {
        string? userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (!Guid.TryParse(userId, out Guid id))
        {
            return null;
        }

        return await _userRepository.GetByIdAsync(id, cancellationToken);
    }

    private void TryDeleteExistingProfilePhoto(string? profileImageUrl)
    {
        if (string.IsNullOrWhiteSpace(profileImageUrl) ||
            !profileImageUrl.StartsWith(
                "/uploads/profile-images/",
                StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        string fileName = Path.GetFileName(profileImageUrl);
        string filePath = Path.Combine(
            _environment.WebRootPath ??
            Path.Combine(_environment.ContentRootPath, "wwwroot"),
            "uploads",
            "profile-images",
            fileName);

        TryDeleteFile(filePath);
    }

    private static void TryDeleteFile(string filePath)
    {
        try
        {
            if (System.IO.File.Exists(filePath))
            {
                System.IO.File.Delete(filePath);
            }
        }
        catch
        {
            // Photo cleanup should not fail the profile update response.
        }
    }
}

public sealed record UpdateProfileNameRequest(string Name);

public sealed record ChangeProfilePasswordRequest(string NewPassword);

public sealed class UploadProfilePhotoRequest
{
    public IFormFile? Photo { get; set; }
}

public sealed record ProfileResponse(
    Guid Id,
    string FullName,
    string Email,
    string PhoneNumber,
    string? ProfileImageUrl,
    bool IsEmailVerified,
    string Status)
{
    public static ProfileResponse FromUser(User user)
    {
        return new ProfileResponse(
            user.Id,
            user.FullName,
            user.Email,
            user.MobileNumber,
            user.ProfileImageUrl,
            user.IsEmailVerified,
            user.Status.ToString());
    }
}
