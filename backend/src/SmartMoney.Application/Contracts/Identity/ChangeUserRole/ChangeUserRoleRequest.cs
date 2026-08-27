namespace SmartMoney.Application.Contracts.Identity.ChangeUserRole;

public sealed class ChangeUserRoleRequest
{
    public string Role { get; set; } = string.Empty;
}
