namespace SmartMoney.Domain.Entities;

public sealed class AffiliateClick
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid UserId { get; set; }

    public User User { get; set; } = null!;

    public Guid StoreId { get; set; }

    public Store Store { get; set; } = null!;

    public Guid? OfferId { get; set; }

    public Offer? Offer { get; set; }

    public Guid AffiliateNetworkId { get; set; }

    public AffiliateNetwork AffiliateNetwork { get; set; } = null!;

    public string TrackingReference { get; set; } = string.Empty;

    public string RedirectToken { get; set; } = string.Empty;

    public string DestinationUrl { get; set; } = string.Empty;

    public string? TrackedUrl { get; set; }

    // First successful redirect only; never overwritten on revisit.
    public DateTime? RedirectedAt { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }
}
