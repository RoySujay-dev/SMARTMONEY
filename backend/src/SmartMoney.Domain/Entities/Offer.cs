using SmartMoney.Domain.Enums;

namespace SmartMoney.Domain.Entities;

public sealed class Offer
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid StoreId { get; set; }

    public Store Store { get; set; } = null!;

    public string Title { get; set; } = string.Empty;

    public string Slug { get; set; } = string.Empty;

    public OfferType OfferType { get; set; }

    public string? ShortDescription { get; set; }

    public string? Description { get; set; }

    public string? TermsAndConditions { get; set; }

    public string? ImageUrl { get; set; }

    public CashbackType CashbackType { get; set; } = CashbackType.None;

    public decimal? CashbackValue { get; set; }

    public string? CashbackText { get; set; }

    public string? CouponCode { get; set; }

    public string DestinationUrl { get; set; } = string.Empty;

    public DateTime? StartAt { get; set; }

    public DateTime? EndAt { get; set; }

    public bool IsFeatured { get; set; }

    public int Priority { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    public ICollection<Banner> Banners { get; set; }
    = new List<Banner>();
}