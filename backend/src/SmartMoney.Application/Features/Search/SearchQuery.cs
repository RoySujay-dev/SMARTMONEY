using SmartMoney.Application.Abstractions.Messaging;
using SmartMoney.Application.Contracts.Search;

namespace SmartMoney.Application.Features.Search;

public sealed record SearchQuery(string Query) : IQuery<SearchResultResponse>;