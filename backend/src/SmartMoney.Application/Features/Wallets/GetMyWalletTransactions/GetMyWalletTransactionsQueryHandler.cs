using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Application.Contracts.Wallets;

namespace SmartMoney.Application.Features.Wallets.GetMyWalletTransactions;

public sealed class GetMyWalletTransactionsQueryHandler
    : IQueryHandler<GetMyWalletTransactionsQuery, WalletTransactionListResponse>
{
    private const int DefaultPageSize = 20;
    private const int MaxPageSize = 100;

    private readonly IWalletTransactionRepository _walletTransactionRepository;

    public GetMyWalletTransactionsQueryHandler(
        IWalletTransactionRepository walletTransactionRepository)
    {
        _walletTransactionRepository = walletTransactionRepository;
    }

    public async Task<WalletTransactionListResponse> HandleAsync(
        GetMyWalletTransactionsQuery query,
        CancellationToken cancellationToken)
    {
        int page = Math.Max(query.Page, 1);
        int pageSize = query.PageSize <= 0
            ? DefaultPageSize
            : Math.Min(query.PageSize, MaxPageSize);

        var transactions = await _walletTransactionRepository.ListByUserIdAsync(
            query.UserId, page, pageSize, cancellationToken);

        var totalCount = await _walletTransactionRepository.CountByUserIdAsync(
            query.UserId, cancellationToken);

        var items = transactions
            .Select(transaction => new WalletTransactionListItemResponse
            {
                Id = transaction.Id,
                Type = transaction.Type.ToString(),
                Amount = transaction.Amount,
                Description = transaction.Description,
                AvailableBalanceAfter = transaction.AvailableBalanceAfter,
                PendingBalanceAfter = transaction.PendingBalanceAfter,
                CreatedAt = transaction.CreatedAt
            })
            .ToList();

        return new WalletTransactionListResponse
        {
            Items = items,
            TotalCount = totalCount,
            Page = page,
            PageSize = pageSize
        };
    }
}
