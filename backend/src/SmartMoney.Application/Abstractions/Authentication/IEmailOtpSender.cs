namespace SmartMoney.Application.Abstractions.Authentication;

public interface IEmailOtpSender
{
    Task SendAsync(
        string email,
        string otp,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Separate from <see cref="SendAsync"/> so the delivered message is
    /// never ambiguous about which action the code authorizes.
    /// </summary>
    Task SendPasswordResetOtpAsync(
        string email,
        string otp,
        CancellationToken cancellationToken = default);
}