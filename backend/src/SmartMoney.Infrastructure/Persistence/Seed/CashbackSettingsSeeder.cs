using Microsoft.EntityFrameworkCore;
using SmartMoney.Domain.Entities;
using SmartMoney.Infrastructure.Persistence.Context;

namespace SmartMoney.Infrastructure.Persistence.Seed;

public static class CashbackSettingsSeeder
{
    /// <summary>
    /// Inserts the single policy row when none exists. Never overwrites an
    /// existing row — the values are owned by operations/admin, not by code.
    /// </summary>
    public static async Task SeedAsync(SmartMoneyDbContext context)
    {
        var exists = await context.CashbackSettings.AnyAsync();

        if (exists)
        {
            return;
        }

        await context.CashbackSettings.AddAsync(new CashbackSettings
        {
            UserSharePercent = 60.00m,
            ConfirmationWindowDays = 60,
        });

        await context.SaveChangesAsync();
    }
}
