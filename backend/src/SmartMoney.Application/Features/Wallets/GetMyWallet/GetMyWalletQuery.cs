using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Wallets;

namespace SmartMoney.Application.Features.Wallets.GetMyWallet;

public sealed class GetMyWalletQuery : IQuery<MyWalletResponse>
{
    public Guid UserId { get; }

    public GetMyWalletQuery(Guid userId)
    {
        UserId = userId;
    }
}
