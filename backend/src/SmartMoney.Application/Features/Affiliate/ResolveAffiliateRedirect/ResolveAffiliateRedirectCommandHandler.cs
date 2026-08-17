using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;

namespace SmartMoney.Application.Features.Affiliate.ResolveAffiliateRedirect;

public sealed class ResolveAffiliateRedirectCommandHandler
    : ICommandHandler<ResolveAffiliateRedirectCommand, string?>
{
    private readonly IAffiliateClickRepository _clickRepository;
    private readonly IUnitOfWork _unitOfWork;

    public ResolveAffiliateRedirectCommandHandler(
        IAffiliateClickRepository clickRepository,
        IUnitOfWork unitOfWork)
    {
        _clickRepository = clickRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<string?> HandleAsync(
        ResolveAffiliateRedirectCommand command,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(command.RedirectToken))
        {
            return null;
        }

        var click = await _clickRepository.GetByRedirectTokenAsync(
            command.RedirectToken, cancellationToken);

        if (click is null)
        {
            return null;
        }

        // First successful redirect only; revisits keep the original timestamp.
        if (click.RedirectedAt is null)
        {
            click.RedirectedAt = DateTime.UtcNow;
            click.UpdatedAt = DateTime.UtcNow;

            await _unitOfWork.SaveChangesAsync(cancellationToken);
        }

        // TrackedUrl (network-wrapped deep link) is populated once the
        // Cuelinks URL contract is integrated; until then the user is sent
        // to the recorded destination directly.
        return click.TrackedUrl ?? click.DestinationUrl;
    }
}
