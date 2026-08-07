using SmartMoney.Domain.Enums;

namespace SmartMoney.Domain.Entities;

public sealed class Banner
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Title { get; set; } = string.Empty;

    public string? Subtitle { get; set; }

    public string ImageUrl { get; set; } = string.Empty;

    public BannerTargetType TargetType { get; set; } = BannerTargetType.None;

    public Guid? StoreId { get; set; }

    public Store? Store { get; set; }

    public Guid? OfferId { get; set; }

    public Offer? Offer { get; set; }

    public Guid? CategoryId { get; set; }

    public Category? Category { get; set; }

    public string? ExternalUrl { get; set; }

    public int DisplayOrder { get; set; }

    public DateTime? StartAt { get; set; }

    public DateTime? EndAt { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }
}