using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Identity.RefreshToken;

namespace SmartMoney.Application.Features.Identity.RefreshToken;

public sealed record RefreshTokenCommand(string RefreshToken)
    : ICommand<RefreshTokenResponse>;
