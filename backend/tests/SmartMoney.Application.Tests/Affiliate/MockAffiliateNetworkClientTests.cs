using SmartMoney.Infrastructure.Affiliate;

namespace SmartMoney.Application.Tests.Affiliate;

public sealed class MockAffiliateNetworkClientTests
{
    private readonly MockAffiliateNetworkClient _client = new();

    [Fact]
    public async Task AppendsSubidToPlainUrl()
    {
        var tracked = await _client.BuildTrackedUrlAsync(
            "https://www.myntra.com", "ref-123");

        Assert.Equal("https://www.myntra.com?subid=ref-123", tracked);
    }

    [Fact]
    public async Task AppendsWithAmpersand_WhenQueryExists()
    {
        var tracked = await _client.BuildTrackedUrlAsync(
            "https://www.myntra.com/deal?x=1", "ref-123");

        Assert.Equal("https://www.myntra.com/deal?x=1&subid=ref-123", tracked);
    }

    [Fact]
    public async Task EscapesTrackingReference()
    {
        var tracked = await _client.BuildTrackedUrlAsync(
            "https://a.example", "r f&x");

        Assert.Equal("https://a.example?subid=r%20f%26x", tracked);
    }

    [Theory]
    [InlineData("not a url")]
    [InlineData("ftp://example.com")]
    [InlineData("javascript:alert(1)")]
    public async Task RejectsNonHttpDestinations(string destination)
    {
        Assert.Null(await _client.BuildTrackedUrlAsync(destination, "ref"));
    }
}
