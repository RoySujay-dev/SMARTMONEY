using SmartMoney.Domain.Enums;

namespace SmartMoney.Application.Features.Identity.ChangeUserRole;

public sealed class ChangeUserRoleValidator
{
    // SuperAdmin is config-seeded only (see SuperAdminSeeder); Support and
    // Finance are unused so far. Keeping the API surface to the two roles the
    // product actually assigns prevents privilege escalation by role name.
    private static readonly RoleType[] AssignableRoles =
    {
        RoleType.Customer,
        RoleType.Admin
    };

    public IReadOnlyCollection<string> Validate(ChangeUserRoleCommand command)
    {
        ArgumentNullException.ThrowIfNull(command);

        var errors = new List<string>();

        if (string.IsNullOrWhiteSpace(command.Role))
        {
            errors.Add("Role is required.");

            return errors;
        }

        if (!Enum.TryParse(command.Role.Trim(), ignoreCase: true, out RoleType parsed)
            || !AssignableRoles.Contains(parsed))
        {
            errors.Add("Role must be either 'Customer' or 'Admin'.");
        }

        return errors;
    }

    public static RoleType ParseRole(string role)
    {
        return Enum.Parse<RoleType>(role.Trim(), ignoreCase: true);
    }
}
