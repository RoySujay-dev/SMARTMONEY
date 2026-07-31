namespace SmartMoney.Application.Features.Identity.RefreshToken;

public sealed class RefreshTokenValidator
{
    public IReadOnlyCollection<string> Validate(RefreshTokenCommand command)
    {
        var errors = new List<string>();

        if (string.IsNullOrWhiteSpace(command.RefreshToken))
        {
            errors.Add("Refresh token is required.");
        }

        return errors;
    }
}
