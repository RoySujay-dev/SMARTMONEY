namespace SmartMoney.Domain.Entities;

public sealed class StoreAffiliateMapping
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid StoreId { get; set; }

    public Store Store { get; set; } = null!;

    public Guid AffiliateNetworkId { get; set; }

    public AffiliateNetwork AffiliateNetwork { get; set; } = null!;

    public string ExternalMerchantId { get; set; } = string.Empty;

    public string? ExternalMerchantName { get; set; }

    public string? MerchantUrl { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime? LastSyncedAt { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }
}