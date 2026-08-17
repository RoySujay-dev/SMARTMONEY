using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Affiliate;

namespace SmartMoney.Application.Features.Affiliate.IngestAffiliateConversion;

public sealed class IngestAffiliateConversionCommand
    : ICommand<IngestAffiliateConversionResponse>
{
    public string NetworkCode { get; }

    public string NetworkTransactionId { get; }

    public string? TrackingReference { get; }

    public string NetworkStatus { get; }

    public decimal? OrderAmount { get; }

    public decimal? CommissionAmount { get; }

    public string? Currency { get; }

    public DateTime? TransactionOccurredAt { get; }

    public DateTime? NetworkUpdatedAt { get; }

    public string? RawPayload { get; }

    public IngestAffiliateConversionCommand(
        string networkCode,
        string networkTransactionId,
        string? trackingReference,
        string networkStatus,
        decimal? orderAmount,
        decimal? commissionAmount,
        string? currency,
        DateTime? transactionOccurredAt,
        DateTime? networkUpdatedAt,
        string? rawPayload)
    {
        NetworkCode = networkCode;
        NetworkTransactionId = networkTransactionId;
        TrackingReference = trackingReference;
        NetworkStatus = networkStatus;
        OrderAmount = orderAmount;
        CommissionAmount = commissionAmount;
        Currency = currency;
        TransactionOccurredAt = transactionOccurredAt;
        NetworkUpdatedAt = networkUpdatedAt;
        RawPayload = rawPayload;
    }
}
