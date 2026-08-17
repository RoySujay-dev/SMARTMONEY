namespace SmartMoney.Application.Contracts.Affiliate;

public sealed record IngestAffiliateConversionRequest(
    string NetworkCode,
    string NetworkTransactionId,
    string? TrackingReference,
    string NetworkStatus,
    decimal? OrderAmount,
    decimal? CommissionAmount,
    string? Currency,
    DateTime? TransactionOccurredAt,
    DateTime? NetworkUpdatedAt,
    string? RawPayload);
