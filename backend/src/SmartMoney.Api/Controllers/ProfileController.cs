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
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IUnitOfWork _unitOfWork;

    public ProfileController(
        IUserRepository userRepository,
        IPasswordHasher passwordHasher,
        IUnitOfWork unitOfWork)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
        _unitOfWork = unitOfWork;
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
}

public sealed record UpdateProfileNameRequest(string Name);

public sealed record ChangeProfilePasswordRequest(string NewPassword);

public sealed record ProfileResponse(
    Guid Id,
    string FullName,
    string Email,
    string PhoneNumber,
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
            user.IsEmailVerified,
            user.Status.ToString());
    }
}
