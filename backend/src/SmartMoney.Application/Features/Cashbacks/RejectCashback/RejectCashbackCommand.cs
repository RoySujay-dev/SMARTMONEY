using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Cashbacks;

namespace SmartMoney.Application.Features.Cashbacks.RejectCashback;

public sealed class RejectCashbackCommand : ICommand<CashbackDecisionResponse?>
{
    public Guid CashbackId { get; }

    public RejectCashbackCommand(Guid cashbackId)
    {
        CashbackId = cashbackId;
    }
}
