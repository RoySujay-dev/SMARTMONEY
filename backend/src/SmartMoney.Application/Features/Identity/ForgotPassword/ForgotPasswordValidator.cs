namespace SmartMoney.Application.Features.Identity.ForgotPassword;

public sealed class ForgotPasswordValidator
{
    public IReadOnlyCollection<string> Validate(ForgotPasswordCommand command)
    {
        ArgumentNullException.ThrowIfNull(command);

        var errors = new List<string>();

        ValidateEmail(command.Email, errors);

        return errors;
    }

    private static void ValidateEmail(string email, ICollection<string> errors)
    {
        if (string.IsNullOrWhiteSpace(email))
        {
            errors.Add("Email is required.");
            return;
        }

        string normalizedEmail = email.Trim();

        try
        {
            var address = new System.Net.Mail.MailAddress(normalizedEmail);

            if (!string.Equals(
                    address.Address,
                    normalizedEmail,
                    StringComparison.OrdinalIgnoreCase))
            {
                errors.Add("Email format is invalid.");
            }
        }
        catch (FormatException)
        {
            errors.Add("Email format is invalid.");
        }
    }
}
