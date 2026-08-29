namespace SmartMoney.Application.Contracts.Cashbacks;

public sealed class AdminCashbackListItemResponse
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public string UserEmail { get; set; } = string.Empty;

    public string UserFullName { get; set; } = string.Empty;

    public string? StoreName { get; set; }

    public decimal CashbackAmount { get; set; }

    public string Status { get; set; } = string.Empty;

    public string NetworkStatus { get; set; } = string.Empty;

    public decimal? OrderAmount { get; set; }

    public decimal? CommissionAmount { get; set; }

    public string? Currency { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime ExpectedConfirmationDate { get; set; }

    public DateTime? ConfirmedDate { get; set; }
}
