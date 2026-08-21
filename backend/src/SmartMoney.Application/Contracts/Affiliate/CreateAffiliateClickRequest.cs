namespace SmartMoney.Application.Contracts.Affiliate;

public sealed record CreateAffiliateClickRequest(
    Guid StoreId,
    Guid? OfferId);
