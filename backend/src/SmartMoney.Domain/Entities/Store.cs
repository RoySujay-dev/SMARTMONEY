namespace SmartMoney.Domain.Entities;

public sealed class Store
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Name { get; set; } = string.Empty;

    public string Slug { get; set; } = string.Empty;

    public string? ShortDescription { get; set; }

    public string? Description { get; set; }

    public string? LogoUrl { get; set; }

    public string? BannerUrl { get; set; }

    public string WebsiteUrl { get; set; } = string.Empty;

    public string? DefaultCashbackText { get; set; }

    public bool IsFeatured { get; set; }

    public int DisplayOrder { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    public ICollection<StoreCategory> StoreCategories { get; set; }
    = new List<StoreCategory>();

    public ICollection<StoreAffiliateMapping> AffiliateMappings { get; set; }
    = new List<StoreAffiliateMapping>();

    public ICollection<Banner> Banners { get; set; }
    = new List<Banner>();

    public ICollection<Offer> Offers { get; set; }
    = new List<Offer>();
}