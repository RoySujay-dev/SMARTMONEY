namespace SmartMoney.Application.Contracts.Affiliate;

public sealed record IngestAffiliateConversionResponse(
    Guid ConversionId,
    string Outcome,
    bool Attributed,
    Guid? AffiliateClickId);
