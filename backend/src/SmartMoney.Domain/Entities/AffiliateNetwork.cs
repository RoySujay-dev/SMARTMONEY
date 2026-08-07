namespace SmartMoney.Domain.Entities;

public sealed class AffiliateNetwork
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Name { get; set; } = string.Empty;

    public string Code { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    public ICollection<StoreAffiliateMapping> StoreMappings { get; set; }
        = new List<StoreAffiliateMapping>();
}