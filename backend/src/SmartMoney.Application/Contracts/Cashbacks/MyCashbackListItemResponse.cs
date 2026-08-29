namespace SmartMoney.Application.Contracts.Cashbacks;

public sealed class MyCashbackListItemResponse
{
    public Guid Id { get; set; }

    public string? StoreName { get; set; }

    public decimal CashbackAmount { get; set; }

    public string Status { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }

    public DateTime ExpectedConfirmationDate { get; set; }

    public DateTime? ConfirmedDate { get; set; }
}
