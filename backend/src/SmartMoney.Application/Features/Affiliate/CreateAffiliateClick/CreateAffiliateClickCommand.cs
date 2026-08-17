using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Affiliate;

namespace SmartMoney.Application.Features.Affiliate.CreateAffiliateClick;

public sealed class CreateAffiliateClickCommand : ICommand<CreateAffiliateClickResponse?>
{
    public Guid UserId { get; }

    public Guid StoreId { get; }

    public Guid? OfferId { get; }

    public CreateAffiliateClickCommand(
        Guid userId,
        Guid storeId,
        Guid? offerId)
    {
        UserId = userId;
        StoreId = storeId;
        OfferId = offerId;
    }
}
