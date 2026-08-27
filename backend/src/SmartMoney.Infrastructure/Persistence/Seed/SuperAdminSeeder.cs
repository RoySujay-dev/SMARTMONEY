using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using SmartMoney.Domain.Enums;
using SmartMoney.Infrastructure.Persistence.Context;

namespace SmartMoney.Infrastructure.Persistence.Seed;

/// <summary>
/// Promotes the account named by the <c>Seed:SuperAdminEmail</c> config key
/// (User Secrets in dev) to SuperAdmin at startup. SuperAdmin is deliberately
/// not grantable through the API — this config-driven path is the only way
/// in. No-ops when the key is unset or the user hasn't registered yet; the
/// user registers first and the next restart promotes them. Idempotent.
/// </summary>
public static class SuperAdminSeeder
{
    public static async Task SeedAsync(
        SmartMoneyDbContext context,
        IConfiguration configuration)
    {
        string? configuredEmail = configuration["Seed:SuperAdminEmail"];

        if (string.IsNullOrWhiteSpace(configuredEmail))
        {
            return;
        }

        string email = configuredEmail.Trim().ToLowerInvariant();

        var user = await context.Users
            .FirstOrDefaultAsync(existingUser => existingUser.Email == email);

        if (user is null)
        {
            return;
        }

        var superAdminRole = await context.Roles
            .FirstAsync(role => role.Name == RoleType.SuperAdmin);

        if (user.RoleId != superAdminRole.Id)
        {
            user.ChangeRole(superAdminRole.Id);

            await context.SaveChangesAsync();
        }
    }
}
