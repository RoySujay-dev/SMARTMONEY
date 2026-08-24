using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;
using SmartMoney.Domain.Enums;

namespace SmartMoney.Application.Features.Affiliate.IngestAffiliateConversion;

/// <summary>
/// Translates a conversion's raw provider status into the user's cashback
/// lifecycle. This is the ONLY place network status strings are interpreted;
/// the domain stores them verbatim.
///
/// MVP safety rule: this is automated code, so it is NEVER allowed to
/// Confirm/Reject/Reverse a cashback on the network's word alone — only a
/// human (via the M6 admin portal, not built yet) can do that. A decisive
/// network status only flags the cashback for admin review; the admin reads
/// the reason off AffiliateConversion.NetworkStatus via the FK.
///
/// The provider's "paid" status means the network was paid by the advertiser,
/// not that Smart Money paid the user — it never touches cashback status at
/// all, automated or otherwise.
/// </summary>
public sealed class ConversionCashbackProcessor
{
    private readonly ICashbackRepository _cashbackRepository;
    private readonly ICashbackSettingsRepository _settingsRepository;
    private readonly IWalletRepository _walletRepository;
    private readonly IAffiliateClickRepository _clickRepository;

    public ConversionCashbackProcessor(
        ICashbackRepository cashbackRepository,
        ICashbackSettingsRepository settingsRepository,
        IWalletRepository walletRepository,
        IAffiliateClickRepository clickRepository)
    {
        _cashbackRepository = cashbackRepository;
        _settingsRepository = settingsRepository;
        _walletRepository = walletRepository;
        _clickRepository = clickRepository;
    }

    /// <summary>
    /// Called after the conversion upsert, before SaveChanges, so cashback
    /// creation/transition commits atomically with the conversion itself.
    /// Never mutates wallet balances — that is the M4 ledger's job.
    /// </summary>
    public async Task ProcessAsync(
        AffiliateConversion conversion,
        CancellationToken cancellationToken)
    {
        // Unattributed conversions carry no user to reward. If attribution is
        // repaired later, the next status update re-enters this path.
        if (conversion.AffiliateClickId is not Guid clickId)
        {
            return;
        }

        var cashback = await _cashbackRepository.GetByConversionIdAsync(
            conversion.Id, cancellationToken);

        switch (Normalize(conversion.NetworkStatus))
        {
            case "pending":
                // No decision being reported yet — just make sure the reward
                // is visible to the user as Pending. No review needed.
                await EnsureCashbackExistsAsync(conversion, clickId, cashback, cancellationToken);
                break;

            case "validated":
            case "rejected":
            case "cancelled":
            case "reversed":
                // The network is reporting a decision, but automated code does
                // not get to act on it — only an admin can Confirm/Reject/
                // Reverse. Queue it for review from whichever state allows it;
                // any other current state (already under review, already
                // terminal) is left untouched.
                cashback ??= await EnsureCashbackExistsAsync(
                    conversion, clickId, cashback, cancellationToken);

                if (cashback is { Status: CashbackStatus.Pending or CashbackStatus.Confirmed })
                {
                    cashback.FlagForReview();
                }

                break;

            // "paid", "invoice_raised" and any unknown status: conversion row
            // is updated by the caller, cashback stays where it is. A "paid"
            // that arrives after a missed "validated" is reconciliation's job,
            // not grounds to skip admin review.
            default:
                break;
        }
    }

    private async Task<Cashback?> EnsureCashbackExistsAsync(
        AffiliateConversion conversion,
        Guid clickId,
        Cashback? existing,
        CancellationToken cancellationToken)
    {
        if (existing is not null)
        {
            return existing;
        }

        // The reward is a share of the commission; no commission, no cashback
        // yet. A later update carrying the amount re-enters here.
        if (conversion.CommissionAmount is not decimal commission || commission <= 0)
        {
            return null;
        }

        var settings = await _settingsRepository.GetAsync(cancellationToken);

        if (settings is null || settings.UserSharePercent <= 0)
        {
            return null;
        }

        var click = await _clickRepository.GetByIdAsync(clickId, cancellationToken);

        if (click is null)
        {
            return null;
        }

        var amount = Math.Round(
            commission * settings.UserSharePercent / 100m,
            2,
            MidpointRounding.AwayFromZero);

        if (amount <= 0)
        {
            return null;
        }

        var wallet = await _walletRepository.GetByUserIdAsync(click.UserId, cancellationToken);

        if (wallet is null)
        {
            wallet = new Wallet(click.UserId);
            await _walletRepository.AddAsync(wallet, cancellationToken);
        }

        var cashback = new Cashback(
            click.UserId,
            wallet.Id,
            conversion.Id,
            amount,
            DateTime.UtcNow.AddDays(settings.ConfirmationWindowDays));

        await _cashbackRepository.AddAsync(cashback, cancellationToken);

        return cashback;
    }

    private static string Normalize(string networkStatus)
    {
        return networkStatus.Trim().ToLowerInvariant();
    }
}
