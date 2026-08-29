using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Application.Contracts.Cashbacks;
using SmartMoney.Domain.Entities;
using SmartMoney.Domain.Enums;

namespace SmartMoney.Application.Features.Cashbacks.ApproveCashback;

/// <summary>
/// Admin decision: confirm a cashback and move its amount from the wallet's
/// pending bucket to available. Null response = cashback not found.
/// </summary>
public sealed class ApproveCashbackCommandHandler
    : ICommandHandler<ApproveCashbackCommand, CashbackDecisionResponse?>
{
    private readonly ICashbackRepository _cashbackRepository;
    private readonly IWalletRepository _walletRepository;
    private readonly IWalletTransactionRepository _walletTransactionRepository;
    private readonly IUnitOfWork _unitOfWork;

    public ApproveCashbackCommandHandler(
        ICashbackRepository cashbackRepository,
        IWalletRepository walletRepository,
        IWalletTransactionRepository walletTransactionRepository,
        IUnitOfWork unitOfWork)
    {
        _cashbackRepository = cashbackRepository;
        _walletRepository = walletRepository;
        _walletTransactionRepository = walletTransactionRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<CashbackDecisionResponse?> HandleAsync(
        ApproveCashbackCommand command,
        CancellationToken cancellationToken)
    {
        var cashback = await _cashbackRepository.GetByIdAsync(
            command.CashbackId, cancellationToken);

        if (cashback is null)
        {
            return null;
        }

        // A cashback can reach AwaitingAdminReview twice: fresh from Pending
        // (money still in the pending bucket) or flagged after a previous
        // Confirm (money already moved to available). Captured BEFORE
        // Confirm() overwrites ConfirmedDate — re-approving must not credit
        // the wallet a second time.
        bool wasPreviouslyConfirmed = cashback.ConfirmedDate is not null;

        cashback.Confirm();

        var wallet = await _walletRepository.GetByIdAsync(
            cashback.WalletId, cancellationToken);

        if (wallet is null)
        {
            throw new InvalidOperationException(
                "Wallet for this cashback was not found.");
        }

        if (!wasPreviouslyConfirmed)
        {
            wallet.ApproveCashback(cashback.CashbackAmount);

            await _walletTransactionRepository.AddAsync(
                new WalletTransaction(
                    wallet.Id,
                    cashback.UserId,
                    WalletTransactionType.CashbackConfirmed,
                    cashback.CashbackAmount,
                    cashback.Id,
                    "Cashback confirmed by admin.",
                    wallet.AvailableBalance,
                    wallet.PendingBalance),
                cancellationToken);
        }

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return new CashbackDecisionResponse
        {
            CashbackId = cashback.Id,
            Status = cashback.Status.ToString(),
            AvailableBalance = wallet.AvailableBalance,
            PendingBalance = wallet.PendingBalance
        };
    }
}
