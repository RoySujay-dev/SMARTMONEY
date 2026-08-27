using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Identity.ChangeUserRole;

namespace SmartMoney.Application.Features.Identity.ChangeUserRole;

public sealed class ChangeUserRoleCommand : ICommand<ChangeUserRoleResponse?>
{
    public Guid TargetUserId { get; }

    public string Role { get; }

    public Guid ActingUserId { get; }

    public ChangeUserRoleCommand(Guid targetUserId, string role, Guid actingUserId)
    {
        TargetUserId = targetUserId;
        Role = role;
        ActingUserId = actingUserId;
    }
}
