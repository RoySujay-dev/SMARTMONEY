namespace SmartMoney.Domain.Entities;

/// <summary>
/// Single-row cashback policy, kept in the database (rather than appsettings)
/// so the future admin panel can tune it without a deployment. Seeded once at
/// startup; never overwritten by the seeder.
/// </summary>
public sealed class CashbackSettings
{
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>
    /// Share of the network commission credited to the user, in percent
    /// (e.g. 60.00 = the user receives 60% of the commission).
    /// </summary>
    public decimal UserSharePercent { get; set; }

    /// <summary>
    /// Days after creation until a pending cashback is expected to confirm.
    /// </summary>
    public int ConfirmationWindowDays { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }
}
