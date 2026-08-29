using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Cashbacks;

namespace SmartMoney.Application.Features.Cashbacks.ReverseCashback;

public sealed class ReverseCashbackCommand : ICommand<CashbackDecisionResponse?>
{
    public Guid CashbackId { get; }

    public ReverseCashbackCommand(Guid cashbackId)
    {
        CashbackId = cashbackId;
    }
}
