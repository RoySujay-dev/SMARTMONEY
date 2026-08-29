using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Cashbacks;

namespace SmartMoney.Application.Features.Cashbacks.ApproveCashback;

public sealed class ApproveCashbackCommand : ICommand<CashbackDecisionResponse?>
{
    public Guid CashbackId { get; }

    public ApproveCashbackCommand(Guid cashbackId)
    {
        CashbackId = cashbackId;
    }
}
