namespace SmartMoney.Domain.Entities;

public sealed class StoreCategory
{
    public Guid StoreId { get; set; }

    public Store Store { get; set; } = null!;

    public Guid CategoryId { get; set; }

    public Category Category { get; set; } = null!;
}