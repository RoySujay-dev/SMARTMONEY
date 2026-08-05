namespace SmartMoney.Domain.Entities;

public sealed class Category
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Name { get; set; } = string.Empty;

    public string Slug { get; set; } = string.Empty;

    public string? Description { get; set; }

    public string? IconUrl { get; set; }

    public int DisplayOrder { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    public ICollection<StoreCategory> StoreCategories { get; set; }
    = new List<StoreCategory>();

    public ICollection<Banner> Banners { get; set; }
    = new List<Banner>();


}