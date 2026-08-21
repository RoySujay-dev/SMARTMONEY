namespace SmartMoney.Domain.Entities;

public sealed class AffiliateConversion
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid AffiliateNetworkId { get; set; }

    public AffiliateNetwork AffiliateNetwork { get; set; } = null!;

    public Guid? AffiliateClickId { get; set; }

    public AffiliateClick? AffiliateClick { get; set; }

    // Provider identifier stored verbatim (trim only); format is provider-defined.
    public string NetworkTransactionId { get; set; } = string.Empty;

    // Raw reference echoed by the provider; kept even when unresolvable
    // so attribution can be retried later.
    public string? TrackingReference { get; set; }

    // Raw provider status string; interpretation happens outside Domain.
    public string NetworkStatus { get; set; } = string.Empty;

    public decimal? OrderAmount { get; set; }

    public decimal? CommissionAmount { get; set; }

    public string? Currency { get; set; }

    // Provider clock: when the purchase happened.
    public DateTime? TransactionOccurredAt { get; set; }

    // Provider clock: provider's last-modified stamp for this record.
    public DateTime? NetworkUpdatedAt { get; set; }

    // Latest raw provider record serialized as JSON; overwritten on update.
    public string? RawPayload { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }
}
