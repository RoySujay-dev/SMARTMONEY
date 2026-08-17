using SmartMoney.Application.Abstractions.Affiliate;
using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Application.Contracts.Affiliate;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Application.Features.Affiliate.CreateAffiliateClick;

public sealed class CreateAffiliateClickCommandHandler
    : ICommandHandler<CreateAffiliateClickCommand, CreateAffiliateClickResponse?>
{
    private readonly IStoreAffiliateMappingRepository _mappingRepository;
    private readonly IOfferRepository _offerRepository;
    private readonly IAffiliateClickRepository _clickRepository;
    private readonly IAffiliateTokenGenerator _tokenGenerator;
    private readonly IUnitOfWork _unitOfWork;

    public CreateAffiliateClickCommandHandler(
        IStoreAffiliateMappingRepository mappingRepository,
        IOfferRepository offerRepository,
        IAffiliateClickRepository clickRepository,
        IAffiliateTokenGenerator tokenGenerator,
        IUnitOfWork unitOfWork)
    {
        _mappingRepository = mappingRepository;
        _offerRepository = offerRepository;
        _clickRepository = clickRepository;
        _tokenGenerator = tokenGenerator;
        _unitOfWork = unitOfWork;
    }

    public async Task<CreateAffiliateClickResponse?> HandleAsync(
        CreateAffiliateClickCommand command,
        CancellationToken cancellationToken)
    {
        var mapping = await _mappingRepository.GetActiveByStoreIdAsync(
            command.StoreId, cancellationToken);

        if (mapping is null)
        {
            return null;
        }

        string destinationUrl = mapping.Store.WebsiteUrl;

        if (command.OfferId is Guid offerId)
        {
            var offer = await _offerRepository.GetActiveByIdAsync(
                offerId, cancellationToken);

            if (offer is null || offer.StoreId != command.StoreId)
            {
                return null;
            }

            destinationUrl = offer.DestinationUrl;
        }

        var click = new AffiliateClick
        {
            UserId = command.UserId,
            StoreId = command.StoreId,
            OfferId = command.OfferId,
            AffiliateNetworkId = mapping.AffiliateNetworkId,
            TrackingReference = _tokenGenerator.GenerateTrackingReference(),
            RedirectToken = _tokenGenerator.GenerateRedirectToken(),
            DestinationUrl = destinationUrl
        };

        await _clickRepository.AddAsync(click, cancellationToken);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return new CreateAffiliateClickResponse(
            click.Id,
            click.RedirectToken,
            $"/r/{click.RedirectToken}");
    }
}
