using NorthStarOps.Application.Features.Support.OpenTickets.Contracts;
using NorthStarOps.Application.Features.Support.OpenTickets.Services;
using Xunit;

namespace NorthStarOps.Tests.Features.Support.OpenTickets;

public sealed class OpenTicketsServiceTests
{
    private readonly OpenTicketsService _sut = new();

    [Fact]
    public void OrderByNewestFirst_EmptyInput_ReturnsEmptyList()
    {
        var result = _sut.OrderByNewestFirst([]);

        Assert.NotNull(result);
        Assert.Empty(result);
    }

    [Fact]
    public void OrderByNewestFirst_MapsAllRequiredFields()
    {
        var input = new[]
        {
            new OpenTicketData("T-001", "Konu", "Open", "High", new DateTime(2026, 1, 10, 12, 0, 0, DateTimeKind.Utc)),
        };

        var result = _sut.OrderByNewestFirst(input);

        var single = Assert.Single(result);
        Assert.Equal("T-001", single.TicketNumber);
        Assert.Equal("Konu", single.Subject);
        Assert.Equal("Open", single.TicketStatus);
        Assert.Equal("High", single.Priority);
    }

    [Fact]
    public void OrderByNewestFirst_MultipleTickets_SortsByCreatedAtDescending()
    {
        var older = new OpenTicketData("T-OLD", "Eski", "Open", "Low", new DateTime(2026, 1, 1, 8, 0, 0, DateTimeKind.Utc));
        var newer = new OpenTicketData("T-NEW", "Yeni", "InProgress", "High", new DateTime(2026, 3, 1, 8, 0, 0, DateTimeKind.Utc));
        var middle = new OpenTicketData("T-MID", "Orta", "Open", "Medium", new DateTime(2026, 2, 1, 8, 0, 0, DateTimeKind.Utc));

        var result = _sut.OrderByNewestFirst([older, newer, middle]);

        Assert.Equal(["T-NEW", "T-MID", "T-OLD"], result.Select(item => item.TicketNumber));
    }
}
