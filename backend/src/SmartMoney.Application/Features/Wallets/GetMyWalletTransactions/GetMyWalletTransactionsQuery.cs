using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Wallets;

namespace SmartMoney.Application.Features.Wallets.GetMyWalletTransactions;

public sealed class GetMyWalletTransactionsQuery : IQuery<WalletTransactionListResponse>
{
    public Guid UserId { get; }

    public int Page { get; }

    public int PageSize { get; }

    public GetMyWalletTransactionsQuery(Guid userId, int page, int pageSize)
    {
        UserId = userId;
        Page = page;
        PageSize = pageSize;
    }
}
